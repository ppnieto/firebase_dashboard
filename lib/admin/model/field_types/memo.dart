import 'package:flutter/material.dart';
import 'package:dashboard/admin/model/admin_modules.dart';

class FieldTypeMemo extends FieldType {
  int maxLines;
  FieldTypeMemo({this.maxLines = 4});
  @override
  getEditContent(value, ColumnModule column, Function onValidate, Function onChange) {
    return TextFormField(
        style: TextStyle(
            //fontFamily: 'HelveticaNeue',
            ),
        initialValue: value,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: column.label,
        ),
        validator: (value) {
          return onValidate != null ? onValidate(value) : null;
        },
        onSaved: (val) {
          if (onChange != null) onChange(val);
        });
  }
}
