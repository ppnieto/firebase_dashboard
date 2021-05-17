import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';

class FieldTypeInlineRef extends FieldTypeRef {
  FieldTypeInlineRef(
      {String collection,
      String refLabel,
      Function getFilter,
      dynamic initialValue,
      Function getQueryCollection})
      : super(
            collection: collection,
            refLabel: refLabel,
            getFilter: getFilter,
            initialValue: initialValue,
            getQueryCollection: getQueryCollection);

  @override
  Widget getListWidget(String content, {TextStyle style}) {
    Query query = getCollection();
    Map<String, dynamic> filters = getFilter != null ? getFilter() : {};
    if (filters != null) {
      for (MapEntry entry in filters.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }
    }
    return StreamBuilder(
      stream: query.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        return Row(children: [
          Text(content, style: style),
          PopupMenuButton<DocumentReference>(
              icon: Icon(Icons.keyboard_arrow_down),
              offset: Offset(0, 36),
              itemBuilder: (context) {
                return [
                      PopupMenuItem<DocumentReference>(
                          value: FirebaseFirestore.instance.doc("values/null"),
                          child: Text("<sin asignar>",
                              style: TextStyle(color: Colors.red)))
                    ] +
                    snapshot.data.docs.map((element) {
                      return PopupMenuItem<DocumentReference>(
                          value: element.reference,
                          child: Text(element.data()[this.refLabel]));
                    }).toList();
              },
              onSelected: (DocumentReference ref) {
                print("selected");
                print(ref.path);
                this.object.reference.update({
                  this.column.field: ref.path == "values/null" ? null : ref
                });
              })
        ]);

/*
        return [
          PopupMenuItem(
              value: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text('Salir'),
              ))
        ];*/
      },
    );
  }

  void test(String content, {TextStyle style}) => DropdownButton<String>(
        value: content,
        //decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 1)),
        items: [
          DropdownMenuItem<String>(
              value: content, child: Text(content, style: style)),
          DropdownMenuItem<String>(
              value: content + "_", child: Text(content, style: style))
        ],
      );
  //Text(content + "-", style: style);
}