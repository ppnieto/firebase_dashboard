import 'package:dashboard/admin/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class FieldType {
  BuildContext context;

  setContext(BuildContext context) {
    this.context = context;
  }

  getListContent(DocumentSnapshot _object, ColumnModule column) => Text(
      _object[column.field] != null ? _object[column.field].toString() : "-");
  getEditContent(Map<String, dynamic> values, ColumnModule column,
      Function onValidate, Function onChange) {
    return Text("No implementado para tipo " + this.toString());
  }

  getFilterContent(value, ColumnModule column, Function onFilter) {
    return Text("No implementado para tipo " + this.toString());
  }
}
