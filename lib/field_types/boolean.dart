import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeBoolean extends FieldType {
  final bool editOnList;
  final bool defValue;

  FieldTypeBoolean({this.editOnList = false, this.defValue = false});
  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    var value = getValue(_object, column) ?? false;

    return IconButton(
      icon: Icon(
        value ? Icons.check_box_outlined : Icons.check_box_outline_blank,
        color: Theme.of(context).primaryColorDark,
      ),
      onPressed: column.editable && editOnList
          ? () {
              _object.reference.set({column.field: !value}, SetOptions(merge: true)).then((value) => print("updated!!!"));
            }
          : null,
    );
  }

  @override
  getValue(DocumentSnapshot<Object?> object, ColumnModule column) {
    var result = super.getValue(object, column);
    if (result is String) {
      result = result.toLowerCase() == 'true';
    }
    return result;
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    {
      var value = _object == null ? values[column.field] : getValue(_object, column);
      if (value == null) value = false;
      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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
}
