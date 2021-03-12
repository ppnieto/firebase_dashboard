import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FieldTypeText extends FieldType {
  final RegExp regexp;
  final bool nullable;
  FieldTypeText({this.nullable, this.regexp});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.data().containsKey(column.field)) {
      if (_object.data()[column.field] != null) {
        return Text(_object[column.field].toString());
      }
    }
    return Text("-");
  }

  @override
  getEditContent(value, ColumnModule column, Function onValidate, Function onChange) {
    return TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: column.label,
        ),
        validator: (value) {
          if (regexp != null) {
            if (!regexp.hasMatch(value)) {
              return "Formato incorrecto";
            }
          }
          return onValidate != null ? onValidate(value) : null;
        },
        onSaved: (val) {
          if (onChange != null) onChange(val);
        });
  }
}
