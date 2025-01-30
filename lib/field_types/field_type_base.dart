import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/controllers/detalle.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class FieldType {
  DashboardModule? module;
  final Map<String, String> preloadedData = {};
  bool async() => false;

  dynamic getFieldFromMap(Map<String, dynamic> data, String fieldName, dynamic defValue) {
    try {
      return data.valueFor(keyPath: fieldName);
    } catch (e) {
      return defValue;
    }
  }

  dynamic getField(DocumentSnapshot object, String fieldName, dynamic defValue) {
    return getFieldFromMap(object.data() as Map<String, dynamic>, fieldName, defValue);
  }

  bool hasField(DocumentSnapshot object, String fieldName) {
    if (fieldName.contains('.')) {
      return (object.data() as Map).valueFor(keyPath: fieldName) != null;
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

  getEditContent(BuildContext context, ColumnModule column) {
    return Text("No implementado para tipo " + this.toString());
  }  
  
  DocumentSnapshot? getObject() {
    DocumentSnapshot? object;
    if (Get.isRegistered<DetalleController>(tag: module?.name)) {
      return Get.find<DetalleController>(tag: module?.name).object;
    }    
    return object;
  }
  getFieldValue(ColumnModule columnModule) {
    Get.log('getFieldValue ${columnModule.field}');
    var value;
    if (Get.isRegistered<DetalleController>(tag: module?.name)) {
      Get.log('   DetalleController is registered');
      var detalleController = Get.find<DetalleController>(tag: module?.name);    
      var updatedData = detalleController.updatedData;
      Get.log('   updateData = $updateData');
      if (updatedData != null) {
        value = updatedData.valueFor(keyPath:columnModule.field);
      } else {
        DocumentSnapshot? object = getObject();
        if (object != null) {
          value = object.get(columnModule.field);
        }
      }
    }
    Get.log('  => $value');
    return value;
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
    updateDataColumnName(context, column.field, value);
  }

  updateDataColumnName(BuildContext context, String columnName, value) {
    Get.log("updateData $columnName => $value (tag ${module?.name})");
    DashboardUtils.findController<DetalleController>(context: context, tag: module?.name)?.updateData(columnName, value);
  }
}

extension SafeFieldAdmin on DocumentSnapshot {
  dynamic getFieldAdm(String fieldName, dynamic defValue) {
    if (!hasFieldAdm(fieldName)) return defValue;
    return get(fieldName);
  }

  bool hasFieldAdm(String fieldName) {
    var docdata = this.data();
    if (docdata is Map) return docdata.valueFor(keyPath: fieldName) != null;
    return false;
  }
}

extension KeyPath on Map {
  Object? valueFor({required String keyPath}) {
    final keysSplit = keyPath.split('.');
    final thisKey = keysSplit.removeAt(0);
    var thisValue;
    if (thisKey.contains('[')) {
      String key = thisKey.substring(0, thisKey.indexOf('['));
      String indexStr = thisKey.substring(thisKey.indexOf('[') + 1, thisKey.indexOf(']'));
      int index = int.parse(indexStr);
      thisValue = this[key][index];
    } else {
      thisValue = this[thisKey];
    }
    if (keysSplit.isEmpty) {
      return thisValue;
    } else if (thisValue is Map) {
      return thisValue.valueFor(keyPath: keysSplit.join('.'));
    }
    return null;
  }

  void updateValueFor({required String keyPath, required value}) {
    Map docdata = this;

    void updateValue(String key, dynamic value) {
      docdata[key] = value;
    }

    Map navigate(String key) {
      if (key.contains('[')) {
        // array de por medio
        String mapKey = key.substring(0, key.indexOf('['));
        int arrayKey = int.parse(key.substring(key.indexOf('[') + 1, key.indexOf(']')));

        return docdata[mapKey][arrayKey];
      } else {
        if (!docdata.containsKey(key)) {
          docdata[key] = {};
        }
        return docdata[key];
      }
    }

    List<String> split = keyPath.split('.');

    while (split.isNotEmpty) {
      var key = split.removeAt(0);
      if (split.isEmpty) {
        updateValue(key, value);
      } else {
        docdata = navigate(key);
      }
    }
  }
}
