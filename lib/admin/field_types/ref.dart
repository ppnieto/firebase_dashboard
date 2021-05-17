import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:flutter/scheduler.dart';

class FieldTypeRef extends FieldType {
  String collection;
  final String refLabel;
  final Function getFilter;
  final dynamic initialValue;
  final Function getQueryCollection;

  static final DocumentReference nullValue =
      FirebaseFirestore.instance.doc("/values/null");

  DocumentSnapshot object;
  ColumnModule column;
  FieldTypeRef(
      {this.collection,
      this.refLabel,
      this.getFilter,
      this.initialValue,
      this.getQueryCollection});

  Widget getListWidget(String content, {TextStyle style}) =>
      Text(content, style: style);

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    this.object = _object;
    this.column = column;
    var _data = _object.data()[column.field];

    if (_data != null && _data is DocumentReference) {
      DocumentReference ref = _data;
      return StreamBuilder(
        stream: ref.snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.data.data() != null &&
              snapshot.data.data().containsKey(this.refLabel)) {
            return getListWidget(snapshot.data.data()[this.refLabel] ?? "-");
          } else
            return getListWidget("<no existe>",
                style: TextStyle(color: Colors.red));
        },
      );
    } else {
      return getListWidget("<sin asignar>",
          style: TextStyle(color: Colors.red));
    }
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
    var value = values[column.field];

    if (value == null) {
      value = initialValue ?? nullValue;
      values[column.field] = value;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onChange(value);
      });
    }

    return StreamBuilder(
        stream: _getQuery().snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Container();

          List<DropdownMenuItem<DocumentReference>> getIfNullable() => [
                DropdownMenuItem<DocumentReference>(
                    value: nullValue, // "-",
                    child: Text("<sin asignar>",
                        style: TextStyle(color: Colors.red)))
              ];

          return Row(children: [
            Text(column.label),
            SizedBox(width: 10),
            Container(
                width: 300,
                child: DropdownButtonFormField<DocumentReference>(
                  value: value,
                  isExpanded: true,
                  items: getIfNullable() +
                      snapshot.data.docs.map((object) {
                        return DropdownMenuItem<DocumentReference>(
                            value: object.reference,
                            child: Text(object.data()[this.refLabel]));
                      }).toList(),
                  onChanged: (val) {
                    if (onChange != null) {
                      onChange(val);
                    }
                  },
                  onSaved: (val) {
                    //if (val.path == nullValue.path) val = null;
                    onChange(val);
                    /*
                    values[column.field] = val;
                    print("onSaved ref");
                    print(values);
                    */
                  },
                  validator: (value) {
                    if (column.mandatory &&
                        (value == null || value.path == nullValue.path))
                      return "Campo obligatorio";
                    return null;
                  },
                ))
          ]);
        });
  }

  @override
  getFilterContent(value, ColumnModule column, Function onFilter) {
    return StreamBuilder(
        stream: _getQuery().snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Container();
          return Row(children: [
            DropdownButton(
              value: value,
              items: <DropdownMenuItem<dynamic>>[
                    DropdownMenuItem(
                        value: "", child: Text("Seleccione " + column.label))
                  ] +
                  snapshot.data.docs.map<DropdownMenuItem<dynamic>>((object) {
                    return DropdownMenuItem(
                        value: object.reference,
                        child: Text(object.data()[this.refLabel]));
                  }).toList(),
              onChanged: (val) {
                if (onFilter != null) onFilter(val);
              },
            )
          ]);
        });
  }
}