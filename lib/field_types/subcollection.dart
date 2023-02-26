import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/screens/detalle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:get/get.dart';

class FieldTypeSubcollection extends FieldType {
  final String subcollection;
  final Module module;
  FieldTypeSubcollection({required this.subcollection, required this.module});

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    return StreamBuilder(
        stream: _object.reference.collection(subcollection).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          return Text(snapshot.data?.docs.length.toString() ?? "0");
        });
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    if (_object == null) return Text("No se puede añadir este contenido en creación");
    module.collection = _object.reference.collection(subcollection).path;
    return StreamBuilder(
        stream: _object.reference.collection(subcollection).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          return Container(
            decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.all(Radius.circular(20))),
            height: 300,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox.shrink(),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Get.put(AdminController(module: module));
                      Get.to(() => DetalleScreen(module: module), id: DashboardMainScreen.dashboardKeyId);
                    },
                  )
                ],
              ),
              Flexible(
                child: ListView(
                  children: snapshot.data!.docs
                      .map((subelement) => InkWell(
                            onTap: () {
                              Get.put(AdminController(module: module));
                              Get.to(() => DetalleScreen(module: module, object: subelement), id: DashboardMainScreen.dashboardKeyId);
                            },
                            child: ListTile(
                              title: Text(subelement.get('nombre')),
                            ),
                          ))
                      .toList(),
                ),
              )
            ]),
          );
        });
  }
}
