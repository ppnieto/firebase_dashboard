import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/controllers/detalle.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class DetalleScreen extends StatelessWidget {
  final DocumentSnapshot? object;
  final double labelWidth;
  final bool showLabel;
  final bool canDelete;
  final DashboardModule module;

  // initialData utilizado para inicializar datos en nuevos objetos
  final Map<String, dynamic>? initialData;

  DetalleScreen({Key? key, this.object, required this.module, this.labelWidth = 120, this.showLabel = true, this.canDelete = true, this.initialData})
      : super(key: key);

/*
  Future<bool> _onWillPop() async {
    return true;
  }
  */

  Future<void> debugInfo(BuildContext context) async {
    Get.showSnackbar(GetSnackBar(
      title: "Info",
      messageText: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (object != null)
          Row(children: [
            Text("Object: ${object?.reference.path}", style: TextStyle(color: Colors.white)),
            IconButton(icon: const Icon(Icons.copy), onPressed: () async => await Clipboard.setData(ClipboardData(text: object!.reference.path)))
          ]),
        Row(children: [
          Text("Module: ${module.name}", style: TextStyle(color: Colors.white)),
        ]),
      ]),
      //message: "Coleccion: ${AppController.to.getCollection(menu).path}\nMenu: ${menu.reference.path}\nModulo: ${module.reference.path}",
      duration: const Duration(seconds: 10),
    ));
  }

  @override
  Widget build(context) {
    Get.log('DetalleScreen::build(${object?.reference.path}) / ${module.name}');
    return GetBuilder<DetalleController>(
        init: DetalleController(module: module, object: object, initialData: initialData),
        tag: module.name,
        builder: (controller) {
          List<Widget> actions = [];
          if (object != null && controller.module.getActions != null) {
            actions = controller.module.getActions!(object!, context);
          }
          if (controller.module.debugInfo) {
            actions.insert(
                0,
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () => debugInfo(context),
                ));
          }

          return Scaffold(
              appBar: AppBar(
                title: Text(controller.module.title + (object == null ? " / nuevo" : " / detalle")),
                centerTitle: false,
                actionsIconTheme: IconThemeData(
                    color: /*DashboardMainScreen.dashboardTheme?.iconButtonColor ??*/
                        Colors.white),
                actions: (actions +
                        [
                          if (AdminController.buttonLocation == ButtonLocation.ActionBar)
                            IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(FontAwesomeIcons.floppyDisk),
                              onPressed: () {
                                controller.doGuardar(context);
                              },
                            ),
                          if (controller.module.canRemove && object != null && controller.canDelete)
                            IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                // no usamos el AdminController por si es un detalle sin listado
                                //AdminController adminController = Modular.get<AdminController>(tag: module.name);
                                AdminController adminController = AdminController(module: module);
                                adminController.doBorrar(context, object!, () {
                                  Navigator.of(context).pop();
                                });
                              },
                            )
                        ])
                    .spacing(10),
              ),
              bottomNavigationBar: AdminController.buttonLocation == ButtonLocation.Bottom
                  ? ElevatedButton.icon(onPressed: () => controller.doGuardar(context), icon: Icon(Icons.save), label: Text("Guardar")).paddingAll(24)
                  : null,
              floatingActionButton: AdminController.buttonLocation == ButtonLocation.Floating
                  ? FloatingActionButton(
                      child: Icon(FontAwesomeIcons.floppyDisk),
                      onPressed: () {
                        controller.doGuardar(context);
                      },
                    )
                  : null,
              body: controller.getDetail(context));
        });
  }
}
