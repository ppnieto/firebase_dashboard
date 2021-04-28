import 'package:flutter/material.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:flutter_spinbox/material.dart';

class FieldTypeNumber extends FieldType {
  final double maxValue;
  final double minValue;
  final double step;
  FieldTypeNumber({this.maxValue = 100, this.minValue = 0, this.step});

  @override
  getEditContent(
      value, ColumnModule column, Function onValidate, Function onChange) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(column.label),
      SizedBox(width: 20),
      Container(
        width: 200,
        child: SpinBox(
          min: this.minValue,
          max: this.maxValue,
          step: this.step,
          value: value ?? 0,
          onChanged: (value) {
            if (onChange != null) onChange(value);
          },
        ),
      )
/*
      SpinnerInput(
          middleNumberWidth: 80,
          middleNumberPadding: EdgeInsets.all(10),
          plusButton: column.editable
              ? SpinnerButtonStyle(color: Colors.blue)
              : SpinnerButtonStyle(height: 0),
          minusButton: column.editable
              ? SpinnerButtonStyle(color: Colors.blue)
              : SpinnerButtonStyle(height: 0),
          spinnerValue: value ?? 0,
//          popupTextStyle: TextStyle(),
          onChange: (val) {
            print("onChange ${val}");
            if (onChange != null) onChange(val);
          })
          */
    ]);
  }
}
