import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/model/admin_modules.dart';

class FieldTypeRef extends FieldType {
  final String collection;
  final String refLabel;
  final Function getFilter;
  final bool nullable;

  FieldTypeRef({this.collection, this.refLabel, this.getFilter, this.nullable = false});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.data()[column.field] != null) {
      return StreamBuilder(
        stream: _object.data()[column.field].snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) return Container();
          return Text(snapshot.data.data()[this.refLabel] ?? "-");
        },
      );
    } else {
      return Text("< sin asignar >", style: TextStyle(color: Colors.red));
    }
  }

  @override
  getEditContent(value, ColumnModule column, Function onValidate, Function onChange) {
    // tmp quitar
    //if (value is String) value = null;

    Query query = FirebaseFirestore.instance.collection(this.collection);
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
          if (snapshot.data.docs.where((element) => element.reference == value).isEmpty) {
            value = null;
          }

          List<DropdownMenuItem> getIfNullable() => this.nullable ? [DropdownMenuItem<DocumentReference>(value: null, child: Text("< sin asignar >", style: TextStyle(color: Colors.red)))] : [];

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
                        return DropdownMenuItem<DocumentReference>(value: object.reference, child: Text(object.data()[this.refLabel]));
                      }).toList(),
                  onChanged: (val) {
                    if (onChange != null) onChange(val);
                  },
                  validator: (value) {
                    if (column.mandatory && value == null) return "Campo obligatorio";
                    return null;
                  },
                ))
          ]);
        });
  }

  @override
  getFilterContent(value, ColumnModule column, Function onFilter) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection(this.collection).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Container();
          return Row(children: [
            DropdownButton(
              value: value,
              items: <DropdownMenuItem<dynamic>>[DropdownMenuItem(value: "", child: Text("Seleccione " + column.label))] +
                  snapshot.data.docs.map<DropdownMenuItem<dynamic>>((object) {
                    return DropdownMenuItem(value: object.reference, child: Text(object.data()[this.refLabel]));
                  }).toList(),
              onChanged: (val) {
                if (onFilter != null) onFilter(val);
              },
            )
          ]);
        });
  }
}
