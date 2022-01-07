import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:dashboard/admin/field_types/field_type_base.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class FieldTypeDateTime extends FieldType {
  final bool showTime;
  final String format;

  FieldTypeDateTime({this.showTime = true, this.format = "dd/MM/yyyy HH:mm"});

  @override
  String getStringContent(DocumentSnapshot _object, ColumnModule column) {
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
    print(column.editable);
    Timestamp? value = _object?.get(column.field);
    //Timestamp? value = _object?.getFieldAdm(column.field, Timestamp.fromDate(DateTime.now()));
    print(value);
    return DateTimePicker(
        enabled: column.editable,
        //locale: Locale('es'),
        type: showTime ? DateTimePickerType.dateTimeSeparate : DateTimePickerType.date,
        dateMask: 'dd/MM/yyyy',
        initialValue: value?.toDate().toString() ?? null,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        icon: Icon(Icons.event),
        dateLabelText: 'Fecha',
        timeLabelText: "Hora",
        onChanged: (val) => print(val),
        validator: (val) {
          if (column.mandatory) {
            if (val == null || val.isEmpty) return "Campo obligatorio";
          }

          return null;
        },
        onSaved: (val) {
//          print("onSaved");
          if (val?.isNotEmpty ?? false) {
            DateTime tmp = DateTime.parse(val!);
            onChange(Timestamp.fromDate(tmp));
          }
        });
  }
}
