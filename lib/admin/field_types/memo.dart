import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';

class FieldTypeMemo extends FieldType {
  int maxLines;
  double? listWidth;
  FieldTypeMemo({this.maxLines = 4, this.listWidth});

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) => listWidth != null
      ? Container(width: this.listWidth, child: super.getListContent(context, _object, column))
      : super.getListContent(context, _object, column);

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    var value = values[column.field];
    return TextFormField(
        enabled: column.editable,
        style: TextStyle(
            //fontFamily: 'HelveticaNeue',
            ),
        initialValue: value,
        maxLines: this.maxLines,
        decoration: InputDecoration(
          labelText: column.label,
        ),
        /*
        validator: (value) {
          return onValidate != null ? onValidate(value) : null;
        },
        */
        onSaved: (val) {
          updateData(context, column, val);
        });
  }
}
