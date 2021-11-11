import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
  getListContent(DocumentSnapshot _object, ColumnModule column) {
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
    if (filters != null) {
      for (MapEntry entry in filters.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }
    }
    return query;
  }

  @override
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column, Function onChange) {
    var value = values[column.field];

    if (value == null) {
      value = initialValue ?? "";
      //values[column.field] = value;
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        onChange(value);
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

          _typeAheadController.text = values[column.field];

          return Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  onChange(this._typeAheadController.text);
                }
              },
              child: TypeAheadFormField(
                noItemsFoundBuilder: (BuildContext context) {
                  return ListTile(
                    //leading: Icon(Icons.shopping_cart),
                    title: Text("No encuentro ninguna marca"),
                  );
                },
                onSaved: (value) {
                  onChange(value);
                },
                textFieldConfiguration: TextFieldConfiguration(
                    controller: this._typeAheadController,
                    decoration: InputDecoration(
                      labelText: column.label,
                    )),
                suggestionsCallback: (pattern) async {
                  return items.where((element) => element.toLowerCase().contains(pattern.toLowerCase()));
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion != null ? suggestion.toString() : ""),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  this._typeAheadController.text = suggestion.toString();
                },
              ));
        });
  }
}
