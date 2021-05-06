import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:dashboard/admin/model/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeSelect extends FieldType {
  final String initialValue;
  final Map<String, String> options;
  final Widget unselected;

  FieldTypeSelect({this.options, this.unselected, this.initialValue});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.data().containsKey(column.field)) {
      if (_object.data()[column.field] != null) {
        String key = _object.data()[column.field];
        if (this.options.containsKey(key)) {
          return Text(this.options[key]);
        } else {
          if (this.unselected != null) {
            return this.unselected;
          }
        }
      }
    }
    return Text("<sin asignar>", style: TextStyle(color: Colors.red));
  }

  @override
  getEditContent(Map<String, dynamic> values, ColumnModule column,
      Function onValidate, Function onChange) {
    var value = values[column.field];

    return Row(children: [
      Text(column.label),
      SizedBox(width: 10),
      Container(
          width: 300,
          child: DropdownButtonFormField(
            value: value == null ? initialValue : value,
            isExpanded: true,
            items: options.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (val) {
              if (onChange != null) onChange(val);
            },
            onSaved: (val) {
              if (onChange != null) onChange(val);
            },
            validator: (value) {
              if (column.mandatory && value == null) return "Campo obligatorio";
              return null;
            },
          )),
    ]);
  }
}
