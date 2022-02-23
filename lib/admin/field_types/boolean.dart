import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeBoolean extends FieldType {
  final bool editOnList;

  FieldTypeBoolean({this.editOnList = false});
  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    bool value = _object.getFieldAdm(column.field, false);
    return IconButton(
      icon: Icon(
          value ? Icons.check_box_outlined : Icons.check_box_outline_blank),
      onPressed: () {
        _object.reference.update({column.field: !value}).then(
            (value) => print("updated!!!"));
      },
    );
    //return Icon(value ? Icons.check_box_outlined : Icons.check_box_outline_blank);
  }

  @override
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values,
      ColumnModule column, Function onChange) {
    var value = values[column.field];

    {
      return CheckboxListTile(
          value: value ?? false,
          onChanged: column.editable
              ? (val) {
                  if (onChange != null) onChange(val);
                }
              : null);
    }
  }

  @override
  Widget getFilterContent(value, ColumnModule column, Function? onFilter) {
    return DropdownButton(
      value: value,
      dropdownColor: Colors.blue,
      style: TextStyle(color: Colors.white),
      items: [
        DropdownMenuItem(child: Text("Seleccione ${column.label}"), value: ""),
        DropdownMenuItem(value: true, child: Text("Si")),
        DropdownMenuItem(value: false, child: Text("No")),
      ],
      onChanged: (val) {
        if (onFilter != null) onFilter(val);
      },
    );
  }
}
