import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class FieldTypeActions extends FieldType {
  final List<FieldTypeAction> actions;
  FieldTypeActions({required this.actions});

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object,
      Map<String, dynamic> values, ColumnModule column) {
    return Container();
  }

  @override
  getListContent(
      BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    return Row(
        children: actions.map((action) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
            icon: Icon(action.iconData, color: Colors.white),
            //color: context != null ? Theme.of(context).primaryColor : Colors.blue,
            label: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(action.title, style: TextStyle(color: Colors.white)),
            ),
            onPressed: () {
              action.onTap(_object, context);
            }),
      );
    }).toList());
  }
}

class FieldTypeAction {
  String title;
  IconData iconData;
  Function onTap;
  FieldTypeAction(
      {this.title = "accion", required this.onTap, required this.iconData});
}
