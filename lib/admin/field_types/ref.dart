import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:flutter/scheduler.dart';

class FieldTypeRef extends FieldType {
  final String? collection;
  final String refLabel;
  final Function? getFilter;
  final dynamic initialValue;
  final Function? getQueryCollection;
  final Function? getStream;
  final Widget? empty;
  final String? otherRef;
  final bool search;

  static final DocumentReference nullValue =
      FirebaseFirestore.instance.doc("/values/null");

  late ColumnModule column;
  FieldTypeRef(
      {this.collection,
      required this.refLabel,
      this.getFilter,
      this.initialValue,
      this.getQueryCollection,
      this.getStream,
      this.otherRef,
      this.search = false,
      this.empty /* = const Text("<sin asignar>", style: TextStyle(color: Colors.red))*/});

  @override
  Future<void> preloadData() async {
    QuerySnapshot qs = await getQuery().get();
    for (var doc in qs.docs) {
      preloadedData[doc.reference.path] = doc.getFieldAdm(refLabel, '');
    }
  }

  @override
  String getSyncStringContent(DocumentSnapshot _object, ColumnModule column) {
    var _data = (_object.data() as Map).containsKey(column.field)
        ? _object.get(column.field)
        : null;
    if (preloadedData.isNotEmpty && _data != null) {
      if (preloadedData.containsKey(_data.path)) {
        return preloadedData[_data.path]!;
      } else {
        return "Error no data preloaded!!!";
      }
    } else {
      return "";
    }
  }

  Widget getListWidget(DocumentSnapshot _object, String content,
          {TextStyle? style}) =>
      Text(content, style: style);

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    this.column = column;
    var _data = (_object.data() as Map).containsKey(column.field)
        ? _object.get(column.field)
        : "-";
    if (_data != null && _data is DocumentReference) {
      if (this.preloadedData.isNotEmpty) {
        return getListWidget(
            _object, this.preloadedData[_data.path] ?? this.otherRef ?? "Otro");
      } else {
        DocumentReference ref = _data;
        return StreamBuilder(
          stream: ref.snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            if (snapshot.data!.data() != null &&
                snapshot.data!.get(this.refLabel) != null) {
              return getListWidget(
                  _object, snapshot.data!.get(this.refLabel) ?? "-");
            } else
              return getListWidget(_object, "<no existe>",
                  style: TextStyle(color: Colors.red));
          },
        );
      }
    } else {
      return this.empty ??
          getListWidget(_object, "<sin asignar>",
              style: TextStyle(color: Colors.red));
    }
  }

  CollectionReference getCollection() {
    if (getQueryCollection != null) {
      return getQueryCollection!();
    } else {
      return FirebaseFirestore.instance.collection(collection!);
    }
  }

  Query getQuery() {
    Query query = getCollection();
    Map<String, dynamic> filters = getFilter != null ? getFilter!() : {};
    if (filters != null) {
      for (MapEntry entry in filters.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }
    }
    return query;
  }

  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values,
      ColumnModule column, Function onChange) {
    var value = values[column.field];

    List<DropdownMenuItem<DocumentReference>> getIfNullable() => [
          DropdownMenuItem<DocumentReference>(
              value: nullValue, // "-",
              child: Text("<sin asignar>", style: TextStyle(color: Colors.red)))
        ];

    if (value == null) {
      value = initialValue ?? nullValue;
      values[column.field] = value;
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        onChange(value);
      });
    }
    if (this.preloadedData.isNotEmpty) {
      if (preloadedData.containsKey(value.path) == false &&
          value != nullValue) {
        return Text(column.label + ": Este campo no se puede editar",
            style: TextStyle(color: Colors.red));
      }

      if (search)
        return Container(
          width: 300,
          child: DropdownSearch<DocumentReference>(
              maxHeight: 500,
              selectedItem: value,
              onChanged: column.editable
                  ? (val) {
                      onChange(val);
                    }
                  : null,
              showSearchBox: search,
              popupTitle: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Text("Seleccione " + column.label,
                    style: TextStyle(fontSize: 22, color: Colors.black)),
              ),
              popupItemBuilder: (context, item, isSelected) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      preloadedData[item.path]?.toString() ?? "-",
                      style: TextStyle(color: Colors.black),
                    ));
              },
              itemAsString: (item) =>
                  preloadedData[item!.path]?.toString() ?? "-",
              items: //getIfNullable() +
                  preloadedData.entries
                      .map((e) => FirebaseFirestore.instance.doc(e.key))
                      .toList()),
        );
      else
        return Row(
          children: [
            Container(
              width: 300,
              child: DropdownButtonFormField<DocumentReference>(
                value: value,
                isExpanded: true,
                items: getIfNullable() +
                    preloadedData.entries.map((entry) {
                      return DropdownMenuItem<DocumentReference>(
                          value: FirebaseFirestore.instance.doc(entry.key),
                          child: Text(entry.value));
                    }).toList(),
                onChanged: column.editable
                    ? (val) {
                        onChange(val);
                      }
                    : null,
                onSaved: (val) {
                  onChange(val);
                },
                validator: (value) {
                  print("validamos campo...");
                  if (column.mandatory &&
                      (value == null || value.path == nullValue.path))
                    return "Campo obligatorio";
                  return null;
                },
              ),
            ),
            SizedBox.shrink(),
          ],
        );
    } else {
      return StreamBuilder(
          stream: getStream == null ? getQuery().snapshots() : getStream!(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();

            late List<QueryDocumentSnapshot> list;
            if (snapshot.data is QuerySnapshot) {
              QuerySnapshot qs = snapshot.data as QuerySnapshot;
              list = qs.docs;
            } else {
              list = snapshot.data as List<QueryDocumentSnapshot>;
            }

            return Row(children: [
              //Text(column.label),
              //SizedBox(width: 10),
              Container(
                  width: 300,
                  child: DropdownButtonFormField<DocumentReference>(
                    value: value,
                    isExpanded: true,
                    items: getIfNullable() +
                        list.map((object) {
                          return DropdownMenuItem<DocumentReference>(
                              value: object.reference,
                              child: Text(object.get(this.refLabel)));
                        }).toList(),
                    onChanged: column.editable
                        ? (val) {
                            if (onChange != null) {
                              onChange(val);
                            }
                          }
                        : null,
                    onSaved: (val) {
                      onChange(val);
                    },
                    validator: (value) {
                      print("validamos campo...");
                      if (column.mandatory &&
                          (value == null || value.path == nullValue.path))
                        return "Campo obligatorio";
                      return null;
                    },
                  ))
            ]);
          });
    }
  }

  @override
  getFilterContent(value, ColumnModule column, Function? onFilter) {
    return StreamBuilder(
        stream: getQuery().snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Container();
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).highlightColor,
            ),
            child: DropdownButton(
              underline: Container(
                height: 0,
                color: Colors.deepPurpleAccent,
              ),
              style: TextStyle(color: Colors.white),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              value: value,
              items: <DropdownMenuItem<dynamic>>[
                    DropdownMenuItem(
                        value: "", child: Text("Seleccione " + column.label))
                  ] +
                  snapshot.data!.docs.map<DropdownMenuItem<dynamic>>((object) {
                    return DropdownMenuItem(
                        value: object.reference,
                        child: Text(object.get(this.refLabel)));
                  }).toList(),
              onChanged: (dynamic val) {
                if (onFilter != null) onFilter(val);
              },
              dropdownColor: Theme.of(context).highlightColor,
            ),
          );
        });
  }

  @override
  getCompareValue(DocumentSnapshot _object, ColumnModule column) {
    var res;
    if (_object.hasFieldAdm(column.field)) {
      res = _object.get(column.field);
      res = preloadedData[res.path];
    } else {
      res = "";
    }
    return res;
  }
}
