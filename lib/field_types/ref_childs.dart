import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class FieldTypeRefNumChilds extends FieldType {
  final String? overrideFieldName;
  final String? collection;
  final Query Function(DocumentSnapshot object)? getCollection;
  final bool Function(QueryDocumentSnapshot)? addFilter;
  final Function(DocumentSnapshot)? onClick;
  final bool filterByField;

  Map<String, int> sizes = {};
  bool preloadAllChildren;
  List<DocumentSnapshot> allChildren = [];

  FieldTypeRefNumChilds(
      {this.collection,
      this.getCollection,
      this.addFilter,
      this.preloadAllChildren = false,
      this.overrideFieldName,
      this.onClick,
      this.filterByField = true});

  Widget _getWidget(String text, DocumentSnapshot object) {
    if (onClick == null) {
      return Text(text);
    } else {
      return OutlinedButton(onPressed: () => onClick!(object), child: Text(text));
    }
  }

  @override
  Future<void> preloadData() async {
    print("preload data");
    if (preloadAllChildren && collection != null) {
      Query col = FirebaseFirestore.instance.collection(collection!);
      QuerySnapshot qs = await col.get();
      allChildren = qs.docs;
      print("preload data ok");
    }
  }

  int addSize(DocumentSnapshot object, int size) {
    sizes[object.reference.path] = size;
    return size;
  }

  Query _getCollection(DocumentSnapshot object) => collection != null ? FirebaseFirestore.instance.collection(collection!) : getCollection!(object);

  Query _getQuery(DocumentSnapshot<Object?> object, ColumnModule column) {
    Query col = _getCollection(object);
    if (filterByField) {
      return col.where(this.overrideFieldName ?? column.field, isEqualTo: object.reference);
    } else {
      return col;
    }
  }

  @override
  Future getAsyncValue(DocumentSnapshot<Object?> object, ColumnModule column) async {
    if (preloadAllChildren) {
      print("get async value preloaded");
      int size = allChildren.length;
      if (filterByField) {
        size = allChildren.where((element) => element.get(this.overrideFieldName ?? column.field) == object.reference).length;
      }
      return addSize(object, size);
    } else {
      if (this.addFilter != null) {
        QuerySnapshot qs = await _getQuery(object, column).get();
        int size = qs.docs.where(addFilter!).toList().length;
        return addSize(object, size);
      } else if (filterByField) {
        AggregateQuerySnapshot qs = await _getQuery(object, column).count().get();
        int size = qs.count ?? 0;
        return addSize(object, size);
      } else {
        AggregateQuerySnapshot qs = await _getCollection(object).count().get();
        int size = qs.count ?? 0;
        print("size = $size");
        return addSize(object, size);
      }
    }
  }

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    print("getListContent (ref childs)");
    Query col = collection != null ? FirebaseFirestore.instance.collection(collection!) : getCollection!(_object);
    if (this.addFilter != null) {
      return FutureBuilder(
        future: _getQuery(_object, column).get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Container();
          String res = "";
          res = snapshot.data!.docs.where(addFilter!).toList().length.toString();
          return _getWidget(res, _object);
        },
      );
    } else {
      if (sizes.containsKey(_object.reference.path)) {
        //print("ya estaba calculado: " + sizes[_object.reference.path].toString());
        return _getWidget(sizes[_object.reference.path].toString(), _object);
      } else {
        //print("no estaba calculado -> future builder");
        return FutureBuilder(
          future: _getQuery(_object, column).count().get(),
          builder: (context, AsyncSnapshot<AggregateQuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Container();
            return _getWidget(snapshot.data!.count.toString(), _object);
          },
        );
      }
    }
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    return SizedBox.shrink();
  }
}
