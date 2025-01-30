import 'package:firebase_dashboard/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FieldTypeLink extends FieldType {
  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (hasField(_object, column.field)) {
      String texto = getField(_object, column.field, "").toString();
      if (texto.isNotEmpty) {
        return IconButton(
            onPressed: () {
              launchUrl(Uri.parse(texto));
            },
            icon: Icon(
              Icons.launch,
              color: Theme.of(context).primaryColor,
            ));
      }
    }
    return SizedBox.shrink();
  }

  @override
  getEditContent(BuildContext context, ColumnModule column) {
    var value = getFieldValue(column);
    
    final TextEditingController controller = TextEditingController();

    controller.text = value ?? "";
    return Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            updateData(context, column, controller.text);
          }
        },
        child: Row(children: [
          Expanded(
            child: TextFormField(
                controller: controller,
                enabled: column.editable,
                decoration: InputDecoration(
                    labelText: column.label,
                    filled: !column.editable,
                    fillColor: column.editable ? Theme.of(context).canvasColor.withAlpha(1) : Theme.of(context).disabledColor),
                validator: (value) {
                  if (column.mandatory && (value == null || value.isEmpty)) return "Campo obligatorio";
                  return null;
                },
                onSaved: (val) {
                  val = (val ?? "").isEmpty ? null : val;
                  updateData(context, column, val);
                }),
          ),
          IconButton(
              onPressed: () {
                launchUrl(Uri.parse(controller.text));
              },
              icon: Icon(Icons.launch, color: Theme.of(context).primaryColor))
        ]));
  }
}
