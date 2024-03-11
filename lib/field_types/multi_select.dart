import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multiselect/multiselect.dart';

class FieldTypeMultiSelect extends FieldType {
  final String hint;
  //final Map<String, dynamic> options;
  final List<String> options;

  FieldTypeMultiSelect({required this.hint, required this.options});

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object,
      Map<String, dynamic> values, ColumnModule column) {
    var value = values[column.field];

    List<String> valueString = value == null ? [] : List<String>.from(value);

    return DropDownMultiSelect(
      onChanged: (List<String> val) {
        updateData(context, column, val);
      },
      //options: List<String>.from(this.options.entries.map((entry) => entry.value).toList()),
      options: this.options,
      selectedValues: valueString,
      whenEmpty: hint,
    );
    /*
    return Theme(
      data: ThemeData(primaryColor: Colors.white),
      child: MultiSelectChipField(
        initialValue: valueString,
        title: Text(hint, style: TextStyle(color: Colors.white)),
        chipColor: Theme.of(context).canvasColor, // accentColor.withOpacity(0.2),
        selectedChipColor: Theme.of(context).highlightColor,
        textStyle: TextStyle(color: Theme.of(context).primaryColor),
        headerColor: Theme.of(context).primaryColor,
        onSaved: (val) {
          print(val);
          updateData(context, column, val);
        },
        items: this.options.entries.map((entry) => MultiSelectItem(entry.key, entry.value)).toList(),
      ),
    );*/
  }

  @override
  getListContent(
      BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      var value = _object[column.field];
      if (value is List) {
        return MultiSelectChipDisplay(
          scroll: true,
          items: value.map((entry) => MultiSelectItem(entry, entry)).toList(),
        );

        //return Text(value.join(","));
        /*
        return MultiSelectChipDisplay(
          items: value.map((entry) => MultiSelectItem(entry, this.options[entry])).toList(),
        );
        */
      }
    }

    return SizedBox.shrink();
  }
}
