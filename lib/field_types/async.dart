import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class FieldTypeAsync extends FieldType {
  final Function(DocumentSnapshot<Object?> object, ColumnModule column)
      getAsyncValueFunction;

  FieldTypeAsync({required this.getAsyncValueFunction});

  @override
  getEditContent(BuildContext context, ColumnModule column) {
    var object = getObject();
    if (object != null) {
      return getListContent(context, object, column);
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  getListContent(
      BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    return FutureBuilder(
      future: getAsyncValue(_object, column),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return Text(snapshot.data!.toString());
      },
    );
  }

  @override
  Future getAsyncValue(DocumentSnapshot<Object?> object, ColumnModule column) {
    return getAsyncValueFunction(object, column);
  }
}
