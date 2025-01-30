import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FieldTypeDate extends FieldType {
  final String format;
  FieldTypeDate({this.format = "dd/MM/yyyy"});

/*
  @override
  String getValue(DocumentSnapshot _object, ColumnModule column) {
    DateTime? dt = getDateTime(_object, column);
    if (dt == null) return "-";
    final f = new DateFormat(this.format);
    return f.format(dt);
  }
  */

/*
  @override
  updateData(BuildContext context, ColumnModule column, value) {
    print("updateDataOverride ${column.field} => $value");
    updateDataColumnName(context, column.field, value);
  }
  */

  DateTime? getDateTime(DocumentSnapshot object, ColumnModule column) {
    if (object.hasFieldAdm(column.field)) {
      var data = object.get(column.field);
      DateTime? dt;
      if (data is String) {
        dt = DateTime.tryParse(data);
      } else if (data is Timestamp) {
        dt = data.toDate();
      }
      return dt;
    }
    return null;
  }

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    DateTime? dt = getDateTime(_object, column);
    final f = new DateFormat(this.format);
    if (dt != null) {
      return Text(f.format(dt));
    } else
      return const SizedBox.shrink();
  }

  @override
  getEditContent(BuildContext context, ColumnModule column) {
    Timestamp? value = getFieldValue(column);

    final f = new DateFormat(this.format);
    TextEditingController txt = TextEditingController();
    if (value != null) {
      txt.text = f.format(value.toDate());
    }

    return Row(children: [
      Expanded(
          child: TextFormField(
        decoration: InputDecoration(
          labelText: column.label,
          filled: !column.editable,
          fillColor: column.editable ? Theme.of(context).canvasColor.withAlpha(1) : Theme.of(context).disabledColor,
        ),
        controller: txt,
        enabled: column.editable,
        validator: (val) {
          if (val!.isEmpty && !column.mandatory) {
            return null;
          }
          try {
            DateFormat(this.format).parse(val);
            return null;
          } catch (e) {
            return "Formato incorrecto";
          }
        },
        onChanged: (val) {
          print("onChanged date $val");
          if (val.isNotEmpty) {
            var tmp = new DateFormat('dd/MM/yyyy').parse(val, true);
            updateData(context, column, Timestamp.fromDate(tmp));
          }
        },
      )),
      if (column.editable)
        IconButton(
          icon: Icon(FontAwesomeIcons.calendar, color: Theme.of(context).primaryColor),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
                locale: Get.locale,
                context: context,
                firstDate: DateTime(2020, 1),
                lastDate: DateTime(2101),
                initialDate: value?.toDate(),
                builder: (BuildContext context, Widget? child) {
                  return Theme(data: ThemeData(), child: child!);
                });
            if (picked != null) {
              txt.text = f.format(picked);
              updateData(context, column, Timestamp.fromDate(picked));
            }
          },
        )
    ]);
  }
}
