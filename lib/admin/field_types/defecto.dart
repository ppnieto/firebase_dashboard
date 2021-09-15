import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeDefecto extends FieldType {
  String defaultField;

  FieldTypeDefecto(this.defaultField);

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.doc("config/parameters").snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.data!.get(this.defaultField) == _object.reference) {
            return Icon(Icons.star, color: Colors.yellow);
          } else {
            return Icon(Icons.star_border_outlined);
          }
        });
  }

  @override
  getEditContent(
      value, ColumnModule column, Function? onValidate, Function onChange) {
    return Container();
  }

  @override
  getFilterContent(value, ColumnModule column, Function onFilter) {
    return Container();
  }
}
