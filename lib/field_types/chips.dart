import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class FieldTypeChips extends FieldType {
  final Map<String, dynamic> options;
  final String hint;

  FieldTypeChips({this.hint = "", required this.options});

  @override
  getEditContent(BuildContext context,  ColumnModule column) {
    var value = getFieldValue(column);
    List<String> valueString = [];
    if (value is List) {
      for (var v in value) {
        valueString.add(v.toString());
      }
    }
    return Theme(
      data: ThemeData(primaryColor: Colors.white),
      child: MultiSelectChipField(
        initialValue: valueString,
        title: Text(hint, style: TextStyle(color: Colors.white)),
        chipColor:
            Theme.of(context).canvasColor, // accentColor.withOpacity(0.2),
        selectedChipColor: Theme.of(context).highlightColor,
        textStyle: TextStyle(color: Theme.of(context).primaryColor),
        headerColor: Theme.of(context).primaryColor,
        onSaved: (val) {
          updateData(context, column, val);
        },
        items: this
            .options
            .entries
            .map((entry) => MultiSelectItem(entry.key, entry.value))
            .toList(),
      ),
    );
  }

  @override
  getListContent(
      BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      var value = _object[column.field];
      List<String> valueString = [];
      if (value is List) {
        for (var v in value) {
          valueString.add(v.toString());
        }
      }

      if (value is List) {
        return MultiSelectChipDisplay(
          items: value
              .map((entry) => MultiSelectItem(entry, this.options[entry]))
              .toList(),
        );
      }
    }

    return SizedBox.shrink();
  }
}
