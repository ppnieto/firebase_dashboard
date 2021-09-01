import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class FieldTypeMultiref extends FieldType {
  String collection;
  final String refLabel;
  final Function getFilter;
  final dynamic initialValue;
  final Function getQueryCollection;

  DocumentSnapshot object;
  FieldTypeMultiref(
      {this.collection,
      this.refLabel,
      this.getFilter,
      this.initialValue,
      this.getQueryCollection});

  Widget getListWidget(String content, {TextStyle style}) =>
      Text(content, style: style);

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.get(column.field) != null) {
      var value = _object[column.field];
      if (value is List) {
        List<DocumentReference> refs = [];
        if (refs is List) {
          for (var obj in value) {
            refs.add(obj);
          }
        }

        print("is List");
        return StreamBuilder(
            stream: Future.wait(refs.map((e) => e.get())).asStream(),
            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              print(snapshot.data);
              return MultiSelectChipDisplay(
                items: snapshot.data.map((entry) {
                  return MultiSelectItem(entry, entry.get(this.refLabel));
                }).toList(),
              );
            });
      }
    }

    return SizedBox.shrink();
  }

  CollectionReference getCollection() {
    if (getQueryCollection != null) {
      return getQueryCollection();
    } else {
      return FirebaseFirestore.instance.collection(collection);
    }
  }

  Query _getQuery() {
    Query query = getCollection();
    Map<String, dynamic> filters = getFilter != null ? getFilter() : {};
    if (filters != null) {
      for (MapEntry entry in filters.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }
    }
    return query;
  }

  @override
  getEditContent(Map<String, dynamic> values, ColumnModule column,
      Function onValidate, Function onChange) {
    print("1");
    var tmp = values[column.field];
    List<DocumentReference> value = [];
    if (tmp is List) {
      for (var obj in tmp) {
        value.add(obj);
      }
    }
/*
    if (value == null) {
      value = initialValue ?? [];
      values[column.field] = value;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onChange(value);
      });
    }
*/
    return StreamBuilder(
        stream: _getQuery().snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Container();

          return MultiSelectDialogField(
            buttonText: Text("Seleccione " + column?.label),
            title: Text("Seleccione " + column?.label),
            initialValue: value,
            items: snapshot.data.docs
                .map((e) => MultiSelectItem(e.reference, e.get(this.refLabel)))
                .toSet()
                .toList(),
            listType: MultiSelectListType.CHIP,
            onConfirm: (values) {
              onChange(values);
            },
          );
        });
  }
}
