import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class FieldTypeDouble extends FieldType {
  final bool emptyNull;
  final Widget nullWidget;
  NumberFormat formatter;

  FieldTypeDouble({this.emptyNull, this.nullWidget, this.formatter}) {
    if (this.formatter == null) this.formatter = NumberFormat.decimalPattern();
  }

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    return Text(this.formatter.format(_object.getFieldAdm(column.field, 0.0)));
  }

  @override
  getEditContent(Map<String, dynamic> values, ColumnModule column,
      Function onValidate, Function onChange) {
    var value = values[column.field];
    return TextFormField(
        initialValue: value != null ? value.toString() : "",
        enabled: column.editable,
        decoration: InputDecoration(
            labelText: column.label,
            filled: !column.editable,
            fillColor: Colors.grey[100]),
        validator: (value) {
          if (value.isNotEmpty) {
            return double.tryParse(value) == null
                ? "Error de formato numérico"
                : null;
          }
          return null;
        },
        onSaved: (val) {
          var doubleval;
          if (val.isNotEmpty) {
            doubleval = double.parse(val);
          } else {
            doubleval = null;
          }
          if (onChange != null) onChange(doubleval);
        });
  }
}
