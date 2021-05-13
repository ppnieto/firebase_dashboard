import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';

class FieldTypeDate extends FieldType {
  final String format;
  FieldTypeDate({this.format = "dd/MM/yyyy"});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    final f = new DateFormat(this.format);
    if (_object.data().containsKey(column.field) &&
        _object.data()[column.field] != null) {
      return Text(f.format(_object.data()[column.field].toDate()));
    } else {
      return Text("-");
    }
  }

  @override
  getEditContent(Map<String, dynamic> values, ColumnModule column,
      Function onValidate, Function onChange) {
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
          try {
            var tmp = new DateFormat(this.format).parse(val);
            return null;
          } catch (e) {
            return "Formato incorrecto";
          }
        },
        onSaved: (val) {
          var tmp = new DateFormat('dd/MM/yyyy').parse(val);
          onChange(Timestamp.fromDate(tmp));
        },
      )),
      IconButton(
        icon: Icon(FontAwesome.calendar),
        onPressed: () async {
          /*
          final DateTime picked = await showDatePicker(context: GlobalModel().navigatorKey.currentContext, firstDate: DateTime(2020, 1), lastDate: DateTime(2101), initialDate: dateTime);
          if (picked != null) {
            txt.text = f.format(picked);
            onChange(Timestamp.fromDate(picked));
          }
          */
        },
      )
    ]);
  }
}
