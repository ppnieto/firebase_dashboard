import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class FieldTypeBoolean extends FieldType {
  final bool editOnList;
  final bool defValue;

  FieldTypeBoolean({this.editOnList = false, this.defValue = false});
  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    var value = getValue(_object, column) ?? defValue;

    return Checkbox(
      value: value,
      onChanged: column.editable && editOnList ? (v) => _object.reference.update({column.field: v}) : null,
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
      if (value == null) value = defValue;
      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        if (Responsive.isMobile(context)) {
          return Row(
            children: [
              Container(constraints: BoxConstraints(minWidth: 120), child: Text(column.label)),
              SizedBox(width: 20),
              Checkbox(
                  value: value ?? false,
                  onChanged: column.editable
                      ? (val) {
                          updateData(context, column, val);
                          setState(() {
                            value = !value;
                          });
                        }
                      : null),
              Spacer()
            ],
          );
        } else {
          return Align(
            alignment: Alignment.centerLeft,
            child: Checkbox(
                value: value ?? false,
                onChanged: column.editable
                    ? (val) {
                        updateData(context, column, val);
                        setState(() {
                          value = !value;
                        });
                      }
                    : null),
          );
        }
      });
    }
  }
}
