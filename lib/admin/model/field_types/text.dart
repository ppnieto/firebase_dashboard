import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FieldTypeText extends FieldType {
  final RegExp regexp;
  final bool nullable;
  final Function showTextFunction;
  final bool obscureText;
  FieldTypeText(
      {this.nullable,
      this.regexp,
      this.showTextFunction,
      this.obscureText = false});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.data().containsKey(column.field)) {
      if (_object.data()[column.field] != null) {
        return Text(showTextFunction == null
            ? _object[column.field].toString()
            : showTextFunction(_object[column.field]));
      }
    }
    return Text("-");
  }

  @override
  getEditContent(Map<String, dynamic> values, ColumnModule column,
      Function onValidate, Function onChange) {
    var value = values[column.field];
    return TextFormField(
        initialValue: value,
        enabled: column.editable,
        obscureText: this.obscureText,
        enableSuggestions: this.obscureText,
        autocorrect: this.obscureText,
        decoration: InputDecoration(
            labelText: column.label,
            filled: !column.editable,
            fillColor: Colors.grey[100]),
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

  @override
  getFilterContent(value, ColumnModule column, Function onFilter) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 250,
      child: TextField(
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Filtrar por " + column.label),
        onChanged: (val) {
          if (onFilter != null) onFilter(val);
        },
      ),
    );
  }
}
