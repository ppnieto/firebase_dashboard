import 'dart:async';

import 'package:firebase_dashboard/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/controllers/dashboard.dart';
import 'package:firebase_dashboard/controllers/detalle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class FieldType {
  final Map<String, String> preloadedData = {};
  bool async = false;

  dynamic getFieldFromMap(Map<String, dynamic> data, String fieldName, dynamic defValue) {
    try {
      if (fieldName.contains('.')) {
        List<String> fields = fieldName.split('.');
        if (fields.length != 2) return "Error con sintaxis de campo $fieldName";
        if (data.containsKey(fields[0])) {
          return data[fields[0]][fields[1]] ?? defValue;
        } else {
          return defValue;
        }
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

  dynamic getValue(DocumentSnapshot object, ColumnModule column) {
    return object.getFieldAdm(column.field, null);
  }

  Future<dynamic> getAsyncValue(DocumentSnapshot object, ColumnModule column) async {
    return getValue(object, column);
  }

  Future<void> preloadData() async {}

  bool showLabel() {
    return false;
  }

  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) => Text((getField(_object, column.field, '-').toString()));

  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
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
    print("updateData ${column.field} => $value");
    updateDataColumnName(context, column.field, value);
  }

  updateDataColumnName(BuildContext context, String columnName, value) {
    DetalleController detalleController = Get.find<DetalleController>(tag: DashboardController.tag);
    detalleController.updateData(columnName, value);
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
