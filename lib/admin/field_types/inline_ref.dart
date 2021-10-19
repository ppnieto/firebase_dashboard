import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';

class FieldTypeInlineRef extends FieldTypeRef {
  FieldTypeInlineRef({String? collection, required String refLabel, Function? getFilter, dynamic initialValue, Function? getQueryCollection})
      : super(collection: collection, refLabel: refLabel, getFilter: getFilter, initialValue: initialValue, getQueryCollection: getQueryCollection);

  @override
  Widget getListWidget(DocumentSnapshot _object, String content, {TextStyle? style}) {
    Query query = getCollection();
    Map<String, dynamic> filters = getFilter != null ? getFilter!() : {};
    if (filters != null) {
      for (MapEntry entry in filters.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }
    }
    return StreamBuilder(
      stream: query.snapshots(),
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
            //icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).highlightColor),
            //offset: Offset(0, 36),
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
  }
}
