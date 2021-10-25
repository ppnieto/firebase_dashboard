import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';

class FieldTypeInlineRef extends FieldTypeRef {
  FieldTypeInlineRef({String? collection, required String refLabel, Function? getFilter, dynamic initialValue, Function? getQueryCollection})
      : super(collection: collection, refLabel: refLabel, getFilter: getFilter, initialValue: initialValue, getQueryCollection: getQueryCollection);

  @override
  Widget getListWidget(DocumentSnapshot _object, String content, {TextStyle? style}) {
    if (preloadedData.isEmpty) {
      return StreamBuilder(
        stream: getQuery().snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          return PopupMenuButton<DocumentReference>(
              tooltip: content,
              child: Text(
                content,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              itemBuilder: (context) {
                return [
                      PopupMenuItem<DocumentReference>(
                          value: FirebaseFirestore.instance.doc("values/null"), child: Text("<sin asignar>", style: TextStyle(color: Colors.red)))
                    ] +
                    snapshot.data!.docs.map((element) {
                      return PopupMenuItem<DocumentReference>(value: element.reference, child: Text(element.get(this.refLabel)));
                    }).toList();
              },
              onSelected: (DocumentReference ref) {
                _object.reference.update({this.column.field: ref.path == "values/null" ? null : ref}).then((value) => print("updated!!!"));
              });
        },
      );
    } else {
      return PopupMenuButton<DocumentReference>(
          tooltip: content,
          child: Text(
            content,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          itemBuilder: (context) {
            return [
                  PopupMenuItem<DocumentReference>(
                      value: FirebaseFirestore.instance.doc("values/null"), child: Text("<sin asignar>", style: TextStyle(color: Colors.red)))
                ] +
                preloadedData.entries.map((e) {
                  return PopupMenuItem<DocumentReference>(value: FirebaseFirestore.instance.doc(e.key), child: Text(e.value));
                }).toList();
          },
          onSelected: (DocumentReference ref) {
            _object.reference.update({this.column.field: ref.path == "values/null" ? null : ref}).then((value) => print("updated!!!"));
          });
    }
  }
}
