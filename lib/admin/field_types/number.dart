import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:flutter_spinbox/material.dart';

class FieldTypeNumber extends FieldType {
  final double maxValue;
  final double minValue;
  final double step;
  final double? defaultValue;
  FieldTypeNumber({this.maxValue = 100, this.minValue = 0, this.step = 1, this.defaultValue});

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    var value = values[column.field];
    if (value == null && defaultValue != null) {
      value = defaultValue;
      updateData(context, column, value);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        width: 200,
        child: SpinBox(
          min: this.minValue,
          max: this.maxValue,
          step: this.step,
          enabled: column.editable,
          value: value ?? minValue,
          onChanged: (value) {
            updateData(context, column, value);
          },
        ),
      ),
      SizedBox.shrink()
    ]);
  }
}
