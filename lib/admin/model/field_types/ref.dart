import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:flutter/scheduler.dart';

class FieldTypeRef extends FieldType {
  String collection;
  final String refLabel;
  final Function getFilter;
  final dynamic initialValue;
  final Function getQueryCollection;

  FieldTypeRef(
      {this.collection,
      this.refLabel,
      this.getFilter,
      this.initialValue,
      this.getQueryCollection});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    var _data = _object.data()[column.field];

    if (_data != null && _data is DocumentReference) {
      DocumentReference ref = _data;
      return StreamBuilder(
        stream: ref.snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.data.data() != null &&
              snapshot.data.data().containsKey(this.refLabel)) {
            return Text(snapshot.data.data()[this.refLabel] ?? "-");
          } else
            return Text("<no existe>", style: TextStyle(color: Colors.red));
        },
      );
    } else {
      return Text("<sin asignar>", style: TextStyle(color: Colors.red));
    }
  }

  CollectionReference _getCollection() {
    if (getQueryCollection != null) {
      return getQueryCollection();
    } else {
      return FirebaseFirestore.instance.collection(collection);
    }
  }

  @override
  getEditContent(Map<String, dynamic> values, ColumnModule column,
      Function onValidate, Function onChange) {
    var value = values[column.field];

    if (value == null) {
      value = initialValue ?? "-";
      values[column.field] = value;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onChange(value);
      });
    }

    Query query = _getCollection();
    Map<String, dynamic> filters = getFilter != null ? getFilter() : {};
    if (filters != null) {
      for (MapEntry entry in filters.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }
    }
    return StreamBuilder(
        stream: query.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Container();
          /*
          if (snapshot.data.docs
              .where((element) => element.reference == value)
              .isEmpty) {
            value = null;
          }*/

          List<DropdownMenuItem> getIfNullable() => [
                DropdownMenuItem(
                    value: "-",
                    child: Text("<sin asignar>",
                        style: TextStyle(color: Colors.red)))
              ];

          return Row(children: [
            Text(column.label),
            SizedBox(width: 10),
            Container(
                width: 300,
                child: DropdownButtonFormField(
                  value: value,
                  isExpanded: true,
                  items: getIfNullable() +
                      snapshot.data.docs.map((object) {
                        print(object.reference);
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
                    if (val == "-") val = null;
                    print("save ${val}");
                    values[column.field] = val;
                  },
                  validator: (value) {
                    if (column.mandatory &&
                        (value == null || value == "" || value == "-"))
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
        stream:
            FirebaseFirestore.instance.collection(this.collection).snapshots(),
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
