import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeWidget extends FieldType {
  final Widget? Function(
      BuildContext context, DocumentSnapshot? object, bool inList) builder;
  FieldTypeWidget({required this.builder});

  @override
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values,
      ColumnModule column, Function onChange) {
    return builder(this.context, _object, false);
  }

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    return builder(this.context, _object, true);
  }
}
