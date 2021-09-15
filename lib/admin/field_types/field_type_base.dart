import 'package:dashboard/admin/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class FieldType {
  late BuildContext context;

  setContext(BuildContext context) {
    this.context = context;
  }

  dynamic getField(
      DocumentSnapshot object, String fieldName, dynamic defValue) {
    if (!hasField(object, fieldName)) return defValue;
    return (object.data() as Map)[fieldName];
  }

  bool hasField(DocumentSnapshot object, String fieldName) {
    if (object.data() == null) return false;
    if (!(object.data() as Map).containsKey(fieldName)) return false;
    if ((object.data() as Map)[fieldName] == null) return false;
    return true;
  }

  getListContent(DocumentSnapshot _object, ColumnModule column) =>
      Text((getField(_object, column.field, '-').toString()));
  getEditContent(Map<String, dynamic> values, ColumnModule column,
      Function? onValidate, Function onChange) {
    return Text("No implementado para tipo " + this.toString());
  }

  getFilterContent(value, ColumnModule column, Function onFilter) {
    return Text("No implementado para tipo " + this.toString());
  }
}

extension SafeFieldAdmin on DocumentSnapshot {
  dynamic getFieldAdm(String fieldName, dynamic defValue) {
    if (!hasFieldAdm(fieldName)) return defValue;
    return (this.data() as Map)[fieldName];
  }

  bool hasFieldAdm(String fieldName) {
    if (this.data() == null) return false;
    if (!(this.data() as Map).containsKey(fieldName)) return false;
    if ((this.data() as Map)[fieldName] == null) return false;
    return true;
  }
}
