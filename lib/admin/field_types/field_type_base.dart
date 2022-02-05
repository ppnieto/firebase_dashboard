import 'package:dashboard/admin/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class FieldType {
  late BuildContext context;
  final Map<String, String> preloadedData = {};

  setContext(BuildContext context) {
    this.context = context;
  }

  dynamic getField(DocumentSnapshot object, String fieldName, dynamic defValue) {
    if (!hasField(object, fieldName)) return defValue;
    return (object.data() as Map)[fieldName];
  }

  bool hasField(DocumentSnapshot object, String fieldName) {
    if (object.data() == null) return false;
    if (!(object.data() as Map).containsKey(fieldName)) return false;
    if ((object.data() as Map)[fieldName] == null) return false;
    return true;
  }

  Future<String> getStringContent(DocumentSnapshot _object, ColumnModule column) async {
    return _object.getFieldAdm(column.field, "-").toString();
  }

  Future<void> preloadData() async {}

  getListContent(DocumentSnapshot _object, ColumnModule column) => Text((getField(_object, column.field, '-').toString()));
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column, Function onChange) {
    return Text("No implementado para tipo " + this.toString());
  }

  getFilterContent(value, ColumnModule column, Function onFilter) {
    return Text("No implementado para tipo " + this.toString());
  }

  getCompareValue(DocumentSnapshot _object, ColumnModule column) {
    var res;
    if (_object.hasFieldAdm(column.field)) {
      res = _object.get(column.field);
    } else {
      res = "";
    }
    return res;
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
