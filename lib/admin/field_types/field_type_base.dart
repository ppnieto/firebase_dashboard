import 'package:dashboard/admin/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class FieldType {
  late BuildContext context;
  final Map<String, String> preloadedData = {};

  setContext(BuildContext context) {
    this.context = context;
  }

  dynamic getFieldFromMap(Map<String, dynamic> data, String fieldName, dynamic defValue) {
    if (fieldName.contains('.')) {
      List<String> fields = fieldName.split('.');
      if (fields.length != 2) return "Error con sintaxis de campo $fieldName";
      return data[fields[0]][fields[1]];
    } else {
      return data[fieldName];
    }
  }

  dynamic getField(DocumentSnapshot object, String fieldName, dynamic defValue) {
    return getFieldFromMap(object.data() as Map<String, dynamic>, fieldName, defValue);
    /*
    if (!hasField(object, fieldName)) return defValue;
    if (fieldName.contains('.')) {
      List<String> fields = fieldName.split('.');
      if (fields.length != 2) return "Error con sintaxis de campo $fieldName";
      return object.get(fields[0])[fields[1]];
    } else {
      return (object.data() as Map)[fieldName];
    }*/
  }

  bool hasField(DocumentSnapshot object, String fieldName) {
    if (fieldName.contains('.')) {
      List<String> fields = fieldName.split('.');
      fieldName = fields[0];
    }
    if (object.data() == null) return false;
    if (!(object.data() as Map).containsKey(fieldName)) return false;
    if ((object.data() as Map)[fieldName] == null) return false;
    return true;
  }

  String getSyncStringContent(DocumentSnapshot _object, ColumnModule column) {
    return _object.getFieldAdm(column.field, "-").toString();
  }

  Future<String> getStringContent(DocumentSnapshot _object, ColumnModule column) async {
    return getSyncStringContent(_object, column);
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
