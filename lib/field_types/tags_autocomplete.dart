import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:flutter/material.dart';
import 'package:super_tag_editor/tag_editor.dart';

class FieldTypeTagsAutocomplete extends FieldType {
  final String hint;
  final TextStyle listStyle;
  final int maxTagsInList;
  final Future<List<String>> Function(String query, DocumentSnapshot? object) findSuggestion;

  FieldTypeTagsAutocomplete(
      {this.hint = "", this.maxTagsInList = 0, this.listStyle = const TextStyle(fontSize: 12, color: Colors.white), required this.findSuggestion});

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    var value;
    if (_object != null && hasField(_object, column.field)) {
      value = _object.get(column.field);
    }

    List<String> valueString = [];
    if (value is String) {
      value = value.split(",");
    }

    if (value is List) {
      for (var v in value) {
        valueString.add(v.toString());
      }
    }

    return StatefulBuilder(builder: (context, setStateBuilder) {
      print("state changed. valueString = ");
      print(valueString);
      return TagEditor(
          delimiters: [",", " "],
          length: valueString.length,
          tagBuilder: (context, index) => _Chip(
                index: index,
                label: valueString[index],
                onDeleted: (index) {
                  valueString.removeAt(index);
                  setStateBuilder(() {
                    updateData(context, column, valueString.join(","));
                  });
                },
              ),
          onTagChanged: (value) {
            print("on tag changed");
            print(value);
            setStateBuilder(() {
              valueString.add(value);
              updateData(context, column, valueString.join(","));
            });
          },
          suggestionBuilder: (context, state, data, index, lenght, highlight, suggestionValid) => ListTile(
                key: ObjectKey(data),
                title: Text(data?.toString() ?? "-"),
                onTap: () {
                  //state.selectSuggestion(data);
                  setStateBuilder(() {
                    valueString.add(data.toString());
                    updateData(context, column, valueString.join(","));
                  });
                },
              ),
          findSuggestions: (query) async {
            return await findSuggestion(query, _object);
          });
    });
  }

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      var value = _object.get(column.field);
      List<String> valueString = [];
      if (value is String) {
        value = value.split(",");
      }
      if (value is List) {
        for (var v in value) {
          valueString.add(v.toString());
        }
      }

      if (value is List) {
        if (maxTagsInList > 0) {
          value = value.take(maxTagsInList);
        }
        return Wrap(
            spacing: 5.0,
            children: value
                .map<Widget>((e) => Container(
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(5))),
                      padding: EdgeInsets.all(6),
                      child: Text(e, style: listStyle),
                    ))
                .toList());
      }
    }

    return SizedBox.shrink();
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onDeleted,
    required this.index,
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: const EdgeInsets.only(left: 8.0),
      label: Text(label),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
      ),
      onDeleted: () {
        onDeleted(index);
      },
    );
  }
}
