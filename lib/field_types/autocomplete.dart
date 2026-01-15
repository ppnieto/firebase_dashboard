/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class FieldTypeAutocomplete extends FieldType {
  final String? collection;
  final String refLabel;
  final Function? getFilter;
  final dynamic initialValue;
  final Function? getQueryCollection;
  final Function? getStream;

  final TextEditingController _typeAheadController = TextEditingController();

  FieldTypeAutocomplete({this.collection, required this.refLabel, this.getFilter, this.initialValue, this.getQueryCollection, this.getStream});

  Widget _getListWidget(DocumentSnapshot _object, String content, {TextStyle? style}) => Text(content, style: style);

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if ((_object.data() as Map).containsKey(column.field)) {
      return Text(_object[column.field].toString());
    }

    return Text("-");
  }

  CollectionReference getCollection() {
    if (getQueryCollection != null) {
      return getQueryCollection!();
    } else {
      return FirebaseFirestore.instance.collection(collection!);
    }
  }

  Query _getQuery() {
    Query query = getCollection();
    Map<String, dynamic> filters = getFilter != null ? getFilter!() : {};
    for (MapEntry entry in filters.entries) {
      query = query.where(entry.key, isEqualTo: entry.value);
    }
    return query;
  }

  @override
  getEditContent(BuildContext context, ColumnModule column) {
    var value = getFieldValue(column);

    if (value == null) {
      value = initialValue ?? "";
      SchedulerBinding.instance.addPostFrameCallback((_) {
        updateData(context, column, value);
      });
    }

    return StreamBuilder(
        stream: getStream == null ? _getQuery().snapshots() : getStream!(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();

          late List<QueryDocumentSnapshot> list;
          if (snapshot.data is QuerySnapshot) {
            QuerySnapshot qs = snapshot.data as QuerySnapshot;
            list = qs.docs;
          } else {
            list = snapshot.data as List<QueryDocumentSnapshot>;
          }

          List<String> items = list.map((e) {
            return (e.data() as Map)[refLabel].toString();
          }).toList();

          _typeAheadController.text = getFieldValue(column);
          if (1 == 2) {
            return Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    updateData(context, column, this._typeAheadController.text);
                  }
                },
                child: TypeAheadField(
                  builder: (context, controller, focusNode) {
                    return TextFormField(
                        controller: this._typeAheadController,
                        focusNode: focusNode,
                        onSaved: (value) {
                          updateData(context, column, value);
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: column.label,
                        ));
                  },
                  emptyBuilder: (BuildContext context) {
                    return ListTile(
                      //leading: Icon(Icons.shopping_cart),
                      title: Text("No encuentro ninguna marca"),
                    );
                  },
                  suggestionsCallback: (pattern) async {
                    print('suggestion $pattern');
                    return List.from(items.where((element) => element.toLowerCase().contains(pattern.toLowerCase())));
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion != null ? suggestion.toString() : ""),
                    );
                  },
                  onSelected: (suggestion) {
                    this._typeAheadController.text = suggestion.toString();
                  },
                ));
          } else {
            return Autocomplete(
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                textEditingController.text = value;
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onFieldSubmitted: (value) {
                    print('field submitted $value');
                    updateData(context, column, value);
                    onFieldSubmitted();
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty && items.contains(value) == false) {
                      return "Valor no válido: $value";
                    }
                  },
                );
              },
              //initialValue: values[column.field],
              optionsBuilder: (TextEditingValue textEditingValue) {
                return items.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                updateData(context, column, selection);
              },
            );
          }
        });
  }
}
*/
