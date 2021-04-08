import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/model/admin_modules.dart';

class FieldTypeImageURL extends FieldType {
  double width;
  double height;
  FieldTypeImageURL({this.width, this.height});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Image.network(
        _object.data()[column.field].toString(),
        width: this.width,
        height: this.height,
      ),
    );
  }

  @override
  getEditContent(
      value, ColumnModule column, Function onValidate, Function onChange) {
    return TextFormField(
        initialValue: value,
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
