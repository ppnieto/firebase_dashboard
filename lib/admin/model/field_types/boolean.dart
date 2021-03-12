import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:dashboard/admin/model/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeBoolean extends FieldType {
  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    bool value = _object.data()[column.field] ?? false;
    return Icon(value ? Icons.check_box_outlined : Icons.check_box_outline_blank);
  }

  @override
  getEditContent(value, ColumnModule column, Function onValidate, Function onChange) {
    {
      return CheckboxListTile(
          title: Text(
            column.label,
          ),
          value: value ?? false,
          onChanged: (val) {
            if (onChange != null) onChange(val);
          });
    }
  }

  @override
  getFilterContent(value, ColumnModule column, Function onFilter) {
    return DropdownButton(
      value: value,
      dropdownColor: Colors.blue,
      style: TextStyle(color: Colors.white),
      items: <DropdownMenuItem<dynamic>>[
        DropdownMenuItem(value: "", child: Text("Seleccione " + column.label)),
        DropdownMenuItem(value: true, child: Text("Si")),
        DropdownMenuItem(value: false, child: Text("No")),
      ],
      onChanged: (val) {
        if (onFilter != null) onFilter(val);
      },
    );
  }
}
