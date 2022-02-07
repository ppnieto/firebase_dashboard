import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class FieldTypeDate extends FieldType {
  final String format;
  FieldTypeDate({this.format = "dd/MM/yyyy"});

  @override
  String getSyncStringContent(DocumentSnapshot _object, ColumnModule column) {
    final f = new DateFormat(this.format);
    if (_object.hasFieldAdm(column.field)) {
      return f.format(_object.get(column.field).toDate());
    } else
      return "-";
  }

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    final f = new DateFormat(this.format);
    if (_object.hasFieldAdm(column.field)) {
      return Text(f.format(_object.get(column.field).toDate()));
    } else
      return Text("-");
  }

  @override
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column, Function onChange) {
    var value = values[column.field];
    final f = new DateFormat(this.format);
    TextEditingController txt = TextEditingController();
    DateTime dateTime;
    if (value != null) {
      txt.text = f.format(value.toDate());
      dateTime = value.toDate();
    } else {
      txt.text = "";
      dateTime = DateTime.now();
    }
    return Row(children: [
      Expanded(
          child: TextFormField(
        decoration: InputDecoration(
          labelText: column.label,
        ),
        controller: txt,
        enabled: column.editable,
        validator: (val) {
          if (val!.isEmpty && !column.mandatory) {
            return null;
          }
          try {
            var tmp = new DateFormat(this.format).parse(val);
            return null;
          } catch (e) {
            return "Formato incorrecto";
          }
        },
        onSaved: (val) {
          if (!val!.isEmpty || column.mandatory) {
            var tmp = new DateFormat('dd/MM/yyyy').parse(val);
            onChange(Timestamp.fromDate(tmp));
          }
        },
      )),
      if (column.editable)
        IconButton(
          icon: Icon(FontAwesomeIcons.calendar),
          onPressed: () async {
            final DateTime? picked =
                await showDatePicker(context: context, firstDate: DateTime(2020, 1), lastDate: DateTime(2101), initialDate: dateTime);
            if (picked != null) {
              txt.text = f.format(picked);
              onChange(Timestamp.fromDate(picked));
            }
          },
        )
    ]);
  }
}
