import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/screens/detalle.dart';
import 'package:flutter/material.dart';

abstract class FieldType {
  final Map<String, String> preloadedData = {};

  dynamic getFieldFromMap(Map<String, dynamic> data, String fieldName, dynamic defValue) {
    try {
      if (fieldName.contains('.')) {
        List<String> fields = fieldName.split('.');
        if (fields.length != 2) return "Error con sintaxis de campo $fieldName";
        return data[fields[0]][fields[1]];
      } else {
        if (!data.containsKey(fieldName)) return defValue;
        return data[fieldName] ?? defValue;
      }
    } catch (e) {
      return defValue;
    }
  }

  dynamic getField(DocumentSnapshot object, String fieldName, dynamic defValue) {
    return getFieldFromMap(object.data() as Map<String, dynamic>, fieldName, defValue);
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
    //return getFieldFromMap(_object.data() as Map<String, dynamic>, column.field, "-");
    return _object.getFieldAdm(column.field, "-").toString();
  }

  Future<String> getStringContent(DocumentSnapshot _object, ColumnModule column) async {
    return getSyncStringContent(_object, column);
  }

  Future<void> preloadData() async {}

  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) => Text((getField(_object, column.field, '-').toString()));

  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    return Text("No implementado para tipo " + this.toString());
  }

  getFilterContent(BuildContext context, value, ColumnModule column, Function onFilter) {
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

  updateData(BuildContext context, ColumnModule column, value) {
    DetalleScreenState? state = context.findAncestorStateOfType<DetalleScreenState>();
    state?.updateData![column.field] = value;
  }
}

extension SafeFieldAdmin on DocumentSnapshot {
  dynamic getFieldAdm(String fieldName, dynamic defValue) {
    bool hasdot = false;
    String subfield = "";
    if (fieldName.contains('.')) {
      List<String> fields = fieldName.split('.');
      fieldName = fields[0];
      subfield = fields[1];
      hasdot = true;
    }

    if (!hasFieldAdm(fieldName)) return defValue;
    Map data = this.data() as Map;
    return hasdot ? data[fieldName][subfield] : data[fieldName];
  }

  bool hasFieldAdm(String fieldName) {
    if (fieldName.contains('.')) {
      List<String> split = fieldName.split('.');
      if (this.hasFieldAdm(split[0])) {
        Map data = this.get(split[0]);
        if (data.containsKey(split[1])) return true;
      }
      return false;
    } else {
      Map data = this.data() as Map;
      //if (data == null) return false;
      if (!data.containsKey(fieldName)) return false;
      if (data[fieldName] == null) return false;
      return true;
    }
  }
}
