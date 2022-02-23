import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:flutter_spinbox/material.dart';

class FieldTypeNumber extends FieldType {
  final double maxValue;
  final double minValue;
  final double step;
  FieldTypeNumber({this.maxValue = 100, this.minValue = 0, this.step = 1});

  @override
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values,
      ColumnModule column, Function onChange) {
    var value = values[column.field];
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      //Text(column.label),
      //SizedBox(width: 20),
      Container(
        width: 200,
        child: SpinBox(
          min: this.minValue,
          max: this.maxValue,
          step: this.step,
          enabled: column.editable,
          value: value ?? 0,
          onChanged: (value) {
            onChange(value);
          },
        ),
      ),
      SizedBox.shrink()
    ]);
  }
}
