import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:dashboard/admin/model/field_types/field_type_base.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class FieldTypeTags extends FieldType {
  final String hint;
  final Map<String, dynamic> options;

  FieldTypeTags({@required this.hint, @required this.options});

  @override
  getEditContent(Map<String, dynamic> values, ColumnModule column,
      Function onValidate, Function onChange) {
    var value = values[column.field];
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
        selectedChipColor: Theme.of(context).accentColor,
        textStyle: TextStyle(color: Theme.of(context).primaryColor),
        headerColor: Theme.of(context).primaryColor,
        onSaved: (val) {
          onChange(val);
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
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.data().containsKey(column.field)) {
      var value = _object[column.field];
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
