import 'package:flutter/material.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:spinner_input/spinner_input.dart';

class FieldTypeNumber extends FieldType {
  @override
  getEditContent(value, ColumnModule column, Function onValidate, Function onChange) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(column.label),
      SizedBox(width: 20),
      SpinnerInput(
          middleNumberWidth: 50,
          plusButton: column.editable ? SpinnerButtonStyle(color: Colors.blue) : SpinnerButtonStyle(height: 0),
          minusButton: column.editable ? SpinnerButtonStyle(color: Colors.blue) : SpinnerButtonStyle(height: 0),
          spinnerValue: value ?? 0,
          popupTextStyle: TextStyle(),
          onChange: (val) {
            if (onChange != null) onChange(val);
          })
    ]);
  }
}
