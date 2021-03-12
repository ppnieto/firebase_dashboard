import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class FieldType {
  getListContent(DocumentSnapshot _object, ColumnModule column) => Text(_object.data().containsKey(column.field) && _object[column.field] != null ? _object[column.field].toString() : "-");
  getEditContent(value, ColumnModule column, Function onValidate, Function onChange) {
    return Text("No implementado para tipo " + this.toString());
  }

  getFilterContent(value, ColumnModule column, Function onFilter) {
    return Text("No implementado para tipo " + this.toString());
  }
}
