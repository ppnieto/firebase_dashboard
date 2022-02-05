import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:dashboard/admin/field_types/field_type_base.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class FieldTypeDateTime extends FieldType {
  final bool showTime;
  final String format;
  final ThemeData? themeData;

  FieldTypeDateTime({this.showTime = true, this.format = "dd/MM/yyyy HH:mm", this.themeData});

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
    var value = values[column.field];
    var dtp = DateTimePicker(
        enabled: column.editable,
        //locale: Locale('es'),
        type: showTime ? DateTimePickerType.dateTimeSeparate : DateTimePickerType.date,
        dateMask: 'dd/MM/yyyy',
        initialValue: value == null ? DateTime.now().toString() : value.toDate().toString(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        icon: Icon(Icons.event),
        dateLabelText: 'Fecha',
        timeLabelText: "Hora",
        onChanged: (val) => print(val),
        validator: (val) {
          print(val);
          return null;
        },
        onSaved: (val) {
          print("on saved");
          print(val);
          DateTime tmp = showTime ? new DateFormat('yyyy-MM-dd HH:mm').parse(val!) : new DateFormat('yyyy-MM-dd').parse(val!);
          onChange(Timestamp.fromDate(tmp));
        });
    if (themeData == null)
      return dtp;
    else {
      return Theme(data: themeData!, child: dtp);
    }
  }
}
