import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/widgets.dart';

class DashListViewStreamBuilder extends StatelessWidget {
  final String? noElementTitle;
  final Widget? noElementWidget;
  final Query query;
  final Widget Function(DocumentSnapshot doc) builder;
  const DashListViewStreamBuilder({super.key, required this.query, required this.builder, this.noElementTitle, this.noElementWidget});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        if (!snapshot.hasData) return DashLoading();
        if (snapshot.data!.docs.isEmpty) return noElementWidget ?? NoElements(title: noElementTitle ?? "No hay datos que mostrar");
        return ListView(children: snapshot.data!.docs.map((e) => builder(e)).toList());
      },
    );
  }
}
