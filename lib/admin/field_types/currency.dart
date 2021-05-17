import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class FieldTypeCurrency extends FieldType {
  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    var formatter = new NumberFormat.currency(locale: "es");
    return Text(formatter.format(_object.data().containsKey(column.field) &&
            _object[column.field] != null
        ? _object[column.field]
        : 0));
  }
}
