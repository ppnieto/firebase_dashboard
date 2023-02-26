import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeDefecto extends FieldType {
  String defaultField;

  FieldTypeDefecto(this.defaultField);

  @override
  getListContent(
      BuildContext context, DocumentSnapshot _object, ColumnModule column) {
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
  getEditContent(BuildContext context, DocumentSnapshot? _object,
      Map<String, dynamic> values, ColumnModule column) {
    return Container();
  }


}
