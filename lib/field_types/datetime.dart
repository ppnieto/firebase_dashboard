import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/field_types/field_type_base.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class FieldTypeDateTime extends FieldType {
  final bool showTime;
  final String format;
  final ThemeData? themeData;

  FieldTypeDateTime(
      {this.showTime = true, this.format = "dd/MM/yyyy HH:mm", this.themeData});

/*  @override
  String getValue(DocumentSnapshot _object, ColumnModule column) {
    final f = new DateFormat(this.format);
    if (_object.hasFieldAdm(column.field)) {
      return f.format(_object.get(column.field).toDate());
    } else
      return "-";
  }*/

  @override
  getListContent(
      BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    final f = new DateFormat(this.format);
    if (_object.hasFieldAdm(column.field)) {
      var d = _object.get(column.field)?.toDate();
      if (d != null) {
        return Text(f.format(d));
      }
    }
    return Text("-");
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object,
      Map<String, dynamic> values, ColumnModule column) {
    Timestamp? value;
    if (_object?.hasFieldAdm(column.field) ?? false) {
      value = _object?.get(column.field);
    } else {
      value = null;
    }
    var dtp = DateTimePicker(
        enabled: column.editable,
        type: showTime
            ? DateTimePickerType.dateTimeSeparate
            : DateTimePickerType.date,
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
            updateData(context, column, Timestamp.fromDate(tmp));
          }
        });
    if (themeData == null)
      return dtp;
    else {
      return Theme(data: themeData!, child: dtp);
    }
  }

  @override
  getCompareValue(DocumentSnapshot _object, ColumnModule column) {
    var res;
    if (_object.hasFieldAdm(column.field)) {
      res = _object.get(column.field);
    } else {
      res = Timestamp(0, 0);
    }
    return res;
  }
}
