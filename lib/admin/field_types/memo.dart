import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';

class FieldTypeMemo extends FieldType {
  int maxLines;
  double listWidth;
  FieldTypeMemo({this.maxLines = 4, this.listWidth});

  @override
  getListContent(
          DocumentSnapshot _object, ColumnModule column) =>
      listWidth != null
          ? Container(
              width: this.listWidth,
              child: super.getListContent(_object, column))
          : super.getListContent(_object, column);

  @override
  getEditContent(Map<String, dynamic> values, ColumnModule column,
      Function onValidate, Function onChange) {
    var value = values[column.field];
    return TextFormField(
        style: TextStyle(
            //fontFamily: 'HelveticaNeue',
            ),
        initialValue: value,
        maxLines: this.maxLines,
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
