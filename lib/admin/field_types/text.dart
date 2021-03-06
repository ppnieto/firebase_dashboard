import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FieldTypeText extends FieldType {
  final RegExp? regexp;
  final bool nullable;
  final Function? showTextFunction;
  final bool obscureText;
  final bool emptyNull;
  final Widget? nullWidget;
  final int ellipsisLength;
  final bool tooltip;
  final int maxLines;
  final String? regExpMessage;

  final TextEditingController controller = TextEditingController();

  FieldTypeText(
      {this.nullable = true,
      this.regexp,
      this.showTextFunction,
      this.obscureText = false,
      this.emptyNull = false,
      this.tooltip = false,
      this.maxLines = 2,
      this.regExpMessage = "Formato incorrecto",
      this.ellipsisLength = 0,
      this.nullWidget});

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (hasField(_object, column.field)) {
      String texto = showTextFunction == null ? getField(_object, column.field, "").toString() : showTextFunction!(_object[column.field]);
      if (this.ellipsisLength > 0 && texto.length >= this.ellipsisLength) {
        return Text(texto);
      } else {
        if (tooltip) {
          return Tooltip(
              message: texto,
              child: Text(
                texto,
                maxLines: this.maxLines,
                overflow: TextOverflow.ellipsis,
              ));
        } else {
          return Text(texto);
        }
      }
    }
    return nullWidget == null ? Text("-") : nullWidget;
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    var value = getFieldFromMap(values, column.field, null);
    value = showTextFunction == null ? value : showTextFunction!(value);

    controller.text = value ?? "";
    return Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            updateData(context, column, controller.text);
          }
        },
        child: TextFormField(
            controller: controller,
            enabled: column.editable,
            obscureText: this.obscureText,
            enableSuggestions: this.obscureText,
            autocorrect: this.obscureText,
            decoration: InputDecoration(
                labelText: column.label,
                filled: !column.editable,
                fillColor: column.editable ? Theme.of(context).canvasColor.withAlpha(1) : Theme.of(context).disabledColor),
            validator: (value) {
              if (regexp != null) {
                if (!regexp!.hasMatch(value ?? "")) {
                  return regExpMessage;
                }
              }

              if (column.mandatory && (value == null || value.isEmpty)) return "Campo obligatorio";
              return null;
            },
            onSaved: (val) {
              if (emptyNull) {
                val = (val ?? "").isEmpty ? null : val;
              }
              updateData(context, column, val);
            }));
  }

  @override
  getFilterContent(BuildContext context, value, ColumnModule column, Function onFilter) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 250,
      child: TextField(
        decoration: InputDecoration(filled: true, fillColor: Colors.white, hintText: "Filtrar por " + column.label),
        onChanged: (val) {
          if (onFilter != null) onFilter(val);
        },
      ),
    );
  }
}
