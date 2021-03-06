import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class FieldTypeMultiref extends FieldType {
  String? collection;
  final String refLabel;
  final Function? getFilter;
  final dynamic? initialValue;
  final CollectionReference Function(DocumentSnapshot?)? getQueryCollection;

  late DocumentSnapshot object;
  FieldTypeMultiref({this.collection, required this.refLabel, this.getFilter, this.initialValue, this.getQueryCollection});

  Widget getListWidget(String content, {TextStyle? style}) => Text(content, style: style);

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
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
        stream: _getQuery(_object).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Container();

          return MultiSelectDialogField<DocumentReference?>(
            //selectedColor: DashboardMainScreen.dashboardTheme!.iconButtonColor,
            /*colorator: (_) {
              return Colors.red;
            },
            */
            //unselectedColor: Colors.red,
            buttonText: Text("Seleccione " + column.label),
            title: Text("Seleccione " + column.label),
            initialValue: value,
            items: snapshot.data!.docs.map((e) => MultiSelectItem(e.reference, e.get(this.refLabel))).toSet().toList(),
            listType: MultiSelectListType.CHIP,
            onConfirm: (values) {
              updateData(context, column, values);
            },
          );
        });
  }
}
