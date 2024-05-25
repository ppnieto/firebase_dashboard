import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class StreamPagination {
  final Query query;
  final int documentLimit;
  final GetxController? getxController;
  bool isLoading = false;
  bool hasMore = true;
  List<DocumentSnapshot> documents = [];
  StreamController<List<DocumentSnapshot>> _streamController =
      StreamController<List<DocumentSnapshot>>();
  Stream<List<DocumentSnapshot>> get stream => _streamController.stream;

  DocumentSnapshot? lastDocument;
  StreamPagination(
      {required this.query, this.documentLimit = 10, this.getxController});

  onInit() {
    getDocuments();
  }

  onClose() {
    _streamController.close();
  }

  getDocuments() async {
    print(
        "streampagination::getDocuments. lastDocument = ${lastDocument?.reference.path}. limit = $documentLimit");
    if (!hasMore) {
      print('no hay mas documentos');
      return;
    }
    if (isLoading) {
      return;
    }
    setLoading(true);
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await query.limit(documentLimit).get();
    } else {
      querySnapshot = await query
          .startAfterDocument(lastDocument!)
          .limit(documentLimit)
          .get();
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }

    if (querySnapshot.docs.isEmpty) {
      print('no hay mas documentos');
      setLoading(false);
      return;
    }

    lastDocument = querySnapshot.docs.lastOrNull;
    print("añadimos al stream ${querySnapshot.docs.length} documentos");
    documents.addAll(querySnapshot.docs);
    _streamController.sink.add(documents);

    setLoading(false);
  }

  void setLoading([bool value = false]) {
    isLoading = value;
    getxController?.update();
  }
}
