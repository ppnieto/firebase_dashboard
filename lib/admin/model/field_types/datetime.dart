import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:dashboard/admin/model/field_types/field_type_base.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:intl/intl.dart';

class FieldTypeDateTime extends FieldType {
  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    final f = new DateFormat('dd/MM/yyyy HH:mm');
    if (_object.data().containsKey(column.field) &&
        _object.data()[column.field] != null) {
      return Text(f.format(_object.data()[column.field].toDate()));
    } else {
      return Text("-");
    }
  }

  @override
  getEditContent(
      value, ColumnModule column, Function onValidate, Function onChange) {
    print(value);
    return DateTimePicker(
        type: DateTimePickerType.dateTimeSeparate,
        dateMask: 'dd/MM/yyyy',
        initialValue: value.toDate().toString(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        icon: Icon(Icons.event),
        dateLabelText: 'Fecha',
        timeLabelText: "Hora",
        selectableDayPredicate: (date) {
          // Disable weekend days to select from the calendar
          if (date.weekday == 6 || date.weekday == 7) {
            return false;
          }

          return true;
        },
        onChanged: (val) => print(val),
        validator: (val) {
          print(val);
          return null;
        },
        onSaved: (val) {
          print("on saved");
          print(val);
          DateTime tmp = new DateFormat('yyyy-MM-dd HH:mm').parse(val);
          onChange(Timestamp.fromDate(tmp));
        });
  }
}
