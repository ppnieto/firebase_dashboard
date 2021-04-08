import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:dashboard/admin/model/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

class FieldTypeActions extends FieldType {
  final List<FieldTypeAction> actions;
  FieldTypeActions({this.actions});

  @override
  getEditContent(
      value, ColumnModule column, Function onValidate, Function onChange) {
    return Container();
  }

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    return Row(
        children: actions.map((action) {
      return RaisedButton.icon(
          icon: Icon(action.iconData, color: Colors.white),
          color: context != null
              ? Theme.of(this.context).primaryColor
              : Colors.blue,
          label: Text(action.title, style: TextStyle(color: Colors.white)),
          onPressed: () {
            if (action.onTap != null) {
              action.onTap(_object, context);
            }
          });
    }).toList());
  }
}

class FieldTypeAction {
  String title;
  IconData iconData;
  Function onTap;
  FieldTypeAction({this.title = "accion", this.onTap, this.iconData});
}
