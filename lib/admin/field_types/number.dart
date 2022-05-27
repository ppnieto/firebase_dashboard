import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:flutter_spinbox/material.dart';

class FieldTypeNumber extends FieldType {
  final double maxValue;
  final double minValue;
  final double step;
  final double? defaultValue;
  final int? decimals;
  FieldTypeNumber({this.maxValue = 100, this.minValue = 0, this.step = 1, this.defaultValue, this.decimals});

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (decimals != null) {
      double num = getField(_object, column.field, 0).toDouble();

      return Text(num.toStringAsFixed(decimals!));
    } else {
      return super.getListContent(context, _object, column);
    }
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    var value = _object?.getFieldAdm(column.field, defaultValue);
    if (_object == null) value = defaultValue;

    if (_object?.hasFieldAdm(column.field) == false) {
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
          value: value,
          onChanged: (value) {
            updateData(context, column, value);
          },
        ),
      ),
      SizedBox.shrink()
    ]);
  }
}
