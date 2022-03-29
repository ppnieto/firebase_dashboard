import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeBoolean extends FieldType {
  final bool editOnList;

  FieldTypeBoolean({this.editOnList = false});
  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    bool value = _object.getFieldAdm(column.field, false);
    return IconButton(
      icon: Icon(value ? Icons.check_box_outlined : Icons.check_box_outline_blank),
      onPressed: column.editable && editOnList
          ? () {
              _object.reference.update({column.field: !value}).then((value) => print("updated!!!"));
            }
          : null,
    );
    //return Icon(value ? Icons.check_box_outlined : Icons.check_box_outline_blank);
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    {
      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        var value = values[column.field];
        return CheckboxListTile(
            value: value ?? false,
            onChanged: column.editable
                ? (val) {
                    updateData(context, column, val);
                    setState(() {
                      value = !value;
                    });
                  }
                : null);
      });
    }
  }

  @override
  Widget getFilterContent(BuildContext context, value, ColumnModule column, Function? onFilter) {
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
