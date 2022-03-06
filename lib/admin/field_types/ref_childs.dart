import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeRefNumChilds extends FieldType {
  final String? overrideFieldName;
  final String? collection;
  final Function? getCollection;
  final bool Function(QueryDocumentSnapshot)? addFilter;

  FieldTypeRefNumChilds({this.collection, this.getCollection, this.addFilter, this.overrideFieldName});

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    print("get list content: " + this.collection.toString());
    Query col = collection != null ? FirebaseFirestore.instance.collection(collection!) : getCollection!(_object);
    return FutureBuilder(
      future: col.where(this.overrideFieldName ?? column.field, isEqualTo: _object.reference).get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Container();
        String res = "";
        if (this.addFilter != null) {
          res = snapshot.data!.docs.where(addFilter!).toList().length.toString();
        } else {
          res = snapshot.data!.docs.length.toString();
        }
        return Text(res);
      },
    );
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    return SizedBox.shrink();
  }
}
