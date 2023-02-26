import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class FieldTypeMultiref extends FieldType {
  String? collection;
  final String refLabel;
  final Function? getFilter;
  final String? rawField;
  final Iterable<DocumentSnapshot> Function(Iterable<DocumentSnapshot>, DocumentSnapshot? object)? doFilter;
  final dynamic? initialValue;
  final MultiSelectListType listType;
  final CollectionReference Function(DocumentSnapshot?)? getQueryCollection;

  late DocumentSnapshot object;
  FieldTypeMultiref(
      {this.collection,
      required this.refLabel,
      this.getFilter,
      this.rawField,
      this.initialValue,
      this.getQueryCollection,
      this.doFilter,
      this.listType = MultiSelectListType.CHIP});

  Widget getListWidget(String content, {TextStyle? style}) => Text(content, style: style);

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      var value = _object[column.field];
      if (value is List) {
        List<DocumentReference> refs = [];
        for (var obj in value) {
          refs.add(obj);
        }

        return StreamBuilder(
            stream: Future.wait(refs.map((e) => e.get())).asStream(),
            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              return MultiSelectChipDisplay(
                textStyle: TextStyle(fontSize: 10),
                scroll: true,
                items: snapshot.data!.map((entry) {
                  return MultiSelectItem(entry, entry.get(this.refLabel));
                }).toList(),
              );
            });
      }
    }

    return SizedBox.shrink();
  }

  CollectionReference getCollection(DocumentSnapshot? _object) {
    if (getQueryCollection != null) {
      return getQueryCollection!(_object);
    } else {
      return FirebaseFirestore.instance.collection(collection!);
    }
  }

  Query _getQuery(DocumentSnapshot? _object) {
    Query query = getCollection(_object);
    Map<String, dynamic> filters = getFilter != null ? getFilter!() : {};
    if (filters != null) {
      for (MapEntry entry in filters.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }
    }
    return query;
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    var tmp = values[column.field];
    List<DocumentReference>? value = [];
    if (tmp is List) {
      for (var obj in tmp) {
        if (obj is DocumentReference) {
          value.add(obj);
        }
      }
    }

    return StreamBuilder(
        stream: _getQuery(_object).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Container();

          Iterable<DocumentSnapshot> docs = snapshot.data!.docs;
          if (doFilter != null) {
            docs = doFilter!(docs, _object);
          }
          Map<DocumentReference, DocumentSnapshot> docMap = Map.fromIterable(
            docs,
            key: (element) => (element as DocumentSnapshot).reference,
            value: (element) => element,
          );

          return MultiSelectDialogField<DocumentReference?>(
            buttonText: Text("Seleccione " + column.label),
            title: Text("Seleccione " + column.label),
            initialValue: value,
            items: docMap.entries.map((e) => MultiSelectItem(e.key, e.value.get(this.refLabel))).toList(),
            listType: listType,
            onConfirm: (values) {
              updateData(context, column, values);
              if (rawField != null) {
                List<String> rawValues = [];
                for (var ref in values) {
                  if (docMap.containsKey(ref)) {
                    DocumentSnapshot doc = docMap[ref]!;
                    rawValues.add(doc.get(this.refLabel));
                  }
                  updateDataColumnName(context, rawField!, rawValues.join(","));
                }
              }
            },
          );
        });
  }

  @override
  Future<void> preloadData() async {
    QuerySnapshot qs = await _getQuery(null).get();
    Iterable<DocumentSnapshot> docs = qs.docs;
    /*
    if (doFilter != null) {
      docs = doFilter!(docs, null);
    }
    */
    for (var doc in docs) {
      preloadedData[doc.reference.path] = doc.getFieldAdm(refLabel, '');
    }
    print("preloadedData");
    print(preloadedData);
  }

  @override
  String getValue(DocumentSnapshot _object, ColumnModule column) {
    List<String> result = [];
    var _datas = _object.getFieldAdm(column.field, null);

    if (preloadedData.isNotEmpty && _datas != null) {
      for (var _data in _datas) {
        if (preloadedData.containsKey(_data.path)) {
          result.add(preloadedData[_data.path]!);
        } else {
          return "Error no data preloaded for key ${_data.path}";
        }
      }
    }
    return result.join(" ");
  }
}
