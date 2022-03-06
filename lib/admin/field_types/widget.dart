import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeWidget extends FieldType {
  final Widget? Function(BuildContext context, DocumentSnapshot? object, bool inList) builder;
  final String Function(DocumentSnapshot? object)? stringContent;

  FieldTypeWidget({required this.builder, this.stringContent});

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    return builder(context, _object, false);
  }

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    return builder(context, _object, true);
  }

  String getSyncStringContent(DocumentSnapshot _object, ColumnModule column) {
    return stringContent != null ? stringContent!(_object) : "";
  }
}
