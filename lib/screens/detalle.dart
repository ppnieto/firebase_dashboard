import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/controllers/detalle.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:sweetsheet/sweetsheet.dart';

class DetalleScreen extends StatelessWidget {
  final DocumentSnapshot? object;
  final double labelWidth;
  final bool showLabel;
  final bool canDelete;
  final Module module;

  DetalleScreen({Key? key, this.object, required this.module, this.labelWidth = 120, this.showLabel = true, this.canDelete = true}) : super(key: key);

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetalleController>(
        init: DetalleController(object: object, module: module),
        tag: module.name,
        builder: (controller) {
          List<Widget> actions = [];
          if (object != null && controller.module.getActions != null) {
            actions = controller.module.getActions!(object!, context);
          }

          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
                appBar: AppBar(
                  title: Text(controller.module.title + (object == null ? " / nuevo" : " / detalle")),
                  backgroundColor: DashboardMainScreen.dashboardTheme?.appBar2BackgroundColor ?? Theme.of(context).secondaryHeaderColor,
                  centerTitle: false,
                  actionsIconTheme: IconThemeData(color: DashboardMainScreen.dashboardTheme?.iconButtonColor ?? Colors.white),
                  actions: (actions +
                          [
                            if (!module.floatingButtons)
                              IconButton(
                                padding: EdgeInsets.all(0),
                                icon: Icon(FontAwesomeIcons.floppyDisk),
                                onPressed: () {
                                  controller.doGuardar();
                                },
                              ),
                            if (controller.module.canRemove && object != null && controller.canDelete)
                              IconButton(
                                padding: EdgeInsets.all(0),
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  // no usamos el AdminController por si es un detalle sin listado
                                  //AdminController adminController = Get.find<AdminController>(tag: module.name);
                                  AdminController adminController = AdminController(module: module);
                                  adminController.doBorrar(context, object!.reference, () {
                                    Navigator.of(context).pop();
                                  });
                                },
                              )
                          ])
                      .spacing(10),
                ),
                floatingActionButton: module.floatingButtons
                    ? FloatingActionButton(
                        child: Icon(FontAwesomeIcons.floppyDisk),
                        onPressed: () {
                          controller.doGuardar();
                        },
                      )
                    : null,
                body: controller.getDetail(context)),
          );
        });
  }
}
