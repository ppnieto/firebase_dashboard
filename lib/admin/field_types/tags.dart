import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:dashboard/admin/field_types/field_type_base.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:textfield_tags/textfield_tags.dart';

class FieldTypeTags extends FieldType {
  final String hint;

  FieldTypeTags({this.hint = ""});

  @override
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column, Function onChange) {
    var value = values[column.field];
    List<String> valueString = [];
    if (value is List) {
      for (var v in value) {
        valueString.add(v.toString());
      }
    }
    return TextFieldTags(
        initialTags: valueString,
        tagsStyler: TagsStyler(
            tagTextStyle: TextStyle(fontWeight: FontWeight.normal),
            tagDecoration: BoxDecoration(
              color: Colors.blue[300],
              borderRadius: BorderRadius.circular(5.0),
            ),
            tagCancelIcon: Icon(Icons.cancel, size: 18.0, color: Colors.blue[900]),
            tagPadding: const EdgeInsets.all(6.0)),
        textFieldStyler: TextFieldStyler(helperText: "Introduzca etiquetas separadas por espacio o coma", hintText: hint),
        onTag: (tag) {
          print("new tag $tag");
          valueString.add(tag);
          onChange(valueString);
        },
        onDelete: (tag) {
          valueString.remove(tag);
          onChange(valueString);
        },
        validator: (tag) {
          /*
            if (tag.length > 15) {
              return "hey that's too long";
            }
            */
          return null;
        });
  }

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      var value = _object[column.field];
      List<String> valueString = [];
      if (value is List) {
        for (var v in value) {
          valueString.add(v.toString());
        }
      }

      if (value is List) {
        return Wrap(
            spacing: 5.0,
            children: valueString
                .map((e) => Container(
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(5))),
                      padding: EdgeInsets.all(6),
                      child: Text(e),
                    ))
                .toList());
      }
    }

    return SizedBox.shrink();
  }
}
