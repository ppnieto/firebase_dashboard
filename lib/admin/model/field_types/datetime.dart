import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:dashboard/admin/model/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class FieldTypeDateTime extends FieldType {
  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    final f = new DateFormat('dd/MM/yyyy HH:mm');
    if (_object.data().containsKey(column.field) &&
        _object.data()[column.field] != null) {
      return Text(f.format(_object.data()[column.field].toDate()));
    } else {
      return Text("-");
    }
  }
}
