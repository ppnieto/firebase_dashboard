import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeRefNumChilds extends FieldType {
  final String collection;

  FieldTypeRefNumChilds({required this.collection});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection(collection).where(column.field, isEqualTo: _object.reference).get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Container();
        return Text(snapshot.data!.docs.length.toString());
      },
    );
  }

  @override
  getEditContent(DocumentSnapshot _object, Map<String, dynamic> values, ColumnModule column, Function onChange) {
    return SizedBox.shrink();
  }
}
