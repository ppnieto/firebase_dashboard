import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/scheduler.dart';

class FieldTypeRef extends FieldType {
  final String? collection;
  final String refLabel;
  final Function? getFilter;
  final Query Function(Query)? filterFunction;
  final dynamic initialValue;
  final Function? getQueryCollection;
  final Function? getStream;
  final Widget? empty;
  final String? otherRef;
  final bool search;
  final TextOverflow? overflow;
  final int? maxLines;
  final void Function(DocumentSnapshot)? onClick;
  final Iterable<DocumentSnapshot> Function(Iterable<DocumentSnapshot>)? doFilter;
  final String? labelField;

  static final DocumentReference nullValue = FirebaseFirestore.instance.doc("/values/null");

  ColumnModule? column;
  FieldTypeRef(
      {this.collection,
      required this.refLabel,
      this.getFilter,
      this.initialValue,
      this.getQueryCollection,
      this.getStream,
      this.otherRef,
      this.filterFunction,
      this.overflow,
      this.maxLines,
      this.onClick,
      this.labelField,
      this.doFilter,
      this.search = false,
      this.empty /* = const Text("<sin asignar>", style: TextStyle(color: Colors.red))*/});

  @override
  bool showLabel() => true;

  @override
  Future<void> preloadData() async {
    Query query = getQuery();
    QuerySnapshot qs = await query.get();
    Iterable<DocumentSnapshot> docs = qs.docs;
    if (doFilter != null) {
      docs = doFilter!(docs);
    }
    for (var doc in docs) {
      preloadedData[doc.reference.path] = doc.getFieldAdm(refLabel, '');
    }
  }

  @override
  Future getAsyncValue(DocumentSnapshot<Object?> object, ColumnModule column) async {
    var _data = object.getFieldAdm(column.field, null);
    if (preloadedData.isNotEmpty && _data != null) {
      if (preloadedData.containsKey(_data.path)) {
        return preloadedData[_data.path]!;
      } else {
        return "Error no data preloaded!!!";
      }
    } else {
      DocumentReference ref = object.get(column.field);
      DocumentSnapshot doc = await ref.get();
      return doc.getFieldAdm(refLabel, '');
    }
  }

  @override
  String getValue(DocumentSnapshot _object, ColumnModule column) {
    var _data = _object.getFieldAdm(column.field, null);
    if (preloadedData.isNotEmpty && _data != null && _data is DocumentReference) {
      if (preloadedData.containsKey(_data.path)) {
        return preloadedData[_data.path]!;
      } else {
        return "Error no data preloaded!!!";
      }
    } else {
      return "";
    }
  }

  Widget getListWidget(BuildContext context, DocumentSnapshot _object, String content, {TextStyle? style}) {
    if (onClick != null) {
      return TextButton(child: Text(content), onPressed: () => onClick!(_object));
    } else {
      return Text(
        content,
        style: style,
        overflow: overflow,
        maxLines: maxLines,
        textAlign: TextAlign.end,
      );
    }
  }

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    this.column = column;
    var _data = _object.getFieldAdm(column.field, "-");
    if (_data != null && _data is DocumentReference) {
      if (this.preloadedData.isNotEmpty) {
        return getListWidget(context, _object, this.preloadedData[_data.path] ?? this.otherRef ?? "Otro",
            style: TextStyle(color: Theme.of(context).primaryColorDark));
      } else {
        DocumentReference ref = _data;
        return StreamBuilder(
          stream: ref.snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            if (snapshot.data!.data() != null && snapshot.data!.hasFieldAdm(this.refLabel)) {
              return getListWidget(context, _object, snapshot.data!.get(this.refLabel) ?? "-",
                  style: TextStyle(color: Theme.of(context).primaryColorDark));
            } else
              return getListWidget(context, _object, "<no existe>", style: TextStyle(color: Colors.red));
          },
        );
      }
    } else {
      return this.empty ?? getListWidget(context, _object, "<sin asignar>", style: TextStyle(color: Colors.red));
    }
  }

  Query getCollection() {
    if (getQueryCollection != null) {
      return getQueryCollection!();
    } else {
      return FirebaseFirestore.instance.collection(collection!);
    }
  }

  Query getQuery() {
    Query query = getCollection();
    Map<String, dynamic> filters = getFilter != null ? getFilter!() : {};

    for (MapEntry entry in filters.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }

    if (this.filterFunction != null) {
      query = filterFunction!(query);
    }

    return query;
  }

  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    var value = values[column.field];

    List<DropdownMenuItem<DocumentReference>> getIfNullable() => [
          DropdownMenuItem<DocumentReference>(
              value: nullValue, // "-",
              child: this.empty ?? Text("<sin asignar>", style: TextStyle(color: Colors.red)))
        ];

    if (value == null) {
      value = _object?.getFieldAdm(column.field, null);
      if (value == null) {
        value = initialValue ?? nullValue;
        values[column.field] = value;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          updateData(context, column, value);
        });
      }
    }
    if (this.preloadedData.isNotEmpty) {
      if (preloadedData.containsKey(value.path) == false && value != nullValue) {
        return Text(column.label + ": Este campo no se puede editar", style: TextStyle(color: Colors.red));
      }

      if (search) {
        print("search ${this.column?.label}");
        List<DocumentReference> docRefs = preloadedData.entries.map((e) => FirebaseFirestore.instance.doc(e.key)).toList();
        TextEditingController textEditingController = TextEditingController();
        print("value = $value");
        return StatefulBuilder(builder: (context, innerSetState) {
          return DropdownButtonHideUnderline(
            child: DropdownButton2<DocumentReference>(
                value: value,
                onChanged: column.editable
                    ? (val) {
                        updateData(context, column, val);
                        if (this.labelField != null && val != null) {
                          updateDataColumnName(context, labelField!, preloadedData[val.path]);
                        }
                        innerSetState(() {
                          value = val;
                        });
                      }
                    : null,
                items: getIfNullable() + docRefs.map((e) => DropdownMenuItem(value: e, child: Text(preloadedData[e.path].toString()))).toList(),
                dropdownSearchData: DropdownSearchData(
                  searchController: textEditingController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      right: 8,
                      left: 8,
                    ),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: 'Buscar...',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return ((preloadedData[item.value?.path] ?? "").toLowerCase().contains(searchValue.toLowerCase()));
                  },
                )),
          );
        });
        /*
        return DropdownSearch<DocumentReference>(
            selectedItem: value,
            onChanged: column.editable
                ? (val) {
                    updateData(context, column, val);
                  }
                : null,
            dropdownDecoratorProps: DropDownDecoratorProps(dropdownSearchDecoration: InputDecoration(labelText: "Name")),
            itemAsString: (item) => preloadedData[item.path]?.toString() ?? "-",
            items: preloadedData.entries.map((e) => FirebaseFirestore.instance.doc(e.key)).toList());*/
      } else {
        return Row(
          children: [
            Container(
              width: 300,
              child: DropdownButtonFormField<DocumentReference>(
                value: value,
                isExpanded: true,
                items: getIfNullable() +
                    preloadedData.entries.map((entry) {
                      return DropdownMenuItem<DocumentReference>(value: FirebaseFirestore.instance.doc(entry.key), child: Text(entry.value));
                    }).toList(),
                onChanged: column.editable
                    ? (val) {
                        updateData(context, column, val);
                        if (this.labelField != null && val != null) {
                          updateDataColumnName(context, labelField!, preloadedData[val.path]);
                        }
                      }
                    : null,
                onSaved: (val) {
                  updateData(context, column, val);
                  if (this.labelField != null && val != null) {
                    updateDataColumnName(context, labelField!, preloadedData[val.path]);
                  }
                },
                validator: (value) {
                  print("validamos campo...");
                  if (column.mandatory && (value == null || value.path == nullValue.path)) return "Campo obligatorio";
                  return null;
                },
              ),
            ),
            SizedBox.shrink(),
          ],
        );
      }
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
                          return DropdownMenuItem<DocumentReference>(value: object.reference, child: Text(object.getFieldAdm(this.refLabel, "?")));
                        }).toList(),
                    onChanged: column.editable
                        ? (val) {
                            updateData(context, column, val);
                          }
                        : null,
                    onSaved: (val) {
                      updateData(context, column, val);
                    },
                    validator: (value) {
                      print("validamos campo...");
                      if (column.mandatory && (value == null || value.path == nullValue.path)) return "Campo obligatorio";
                      return null;
                    },
                  ))
            ]);
          });
    }
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
