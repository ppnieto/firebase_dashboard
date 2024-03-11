import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/controllers/dashboard.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  static DashboardService get to => Get.find(); // add this line

  factory DashboardService() {
    return _instance;
  }

  DashboardService._internal();

  static DashboardService get instance => _instance;

  //Map<String, DashboardModule> _modules = {};
  //Map<Type, GetxController> _controllers = {};

  int dashboardKeyId = 100;

  //bool hasModule(String moduleName) => _modules.containsKey(moduleName);
  //DashboardModule? module(String moduleName) => hasModule(moduleName) ? _modules[moduleName] : null;

  //bool hasController(Type type) => _controllers.containsKey(type);
  //DashController? controller(Type type) => hasController(type) ? _controllers[type] : null;

  //void registerModule(DashboardModule module) {
//    _modules[module.name] = module;
//  }

/*
  void registerController(DashController controller) {
    print("register controller " + controller.runtimeType.toString());
    _controllers[controller.runtimeType] = controller;
    print(_controllers);
  }

  void unregisterController(DashController controller) {
    print("unregister controller");
    print(_controllers);
    _controllers.removeWhere((key, value) => value == controller);
    print(_controllers);
  }
  */

  void showDetalle({DocumentSnapshot? object, required DashboardModule module, bool canDelete = true}) {
    Get.log('showDetalle ${module.name} ${object?.reference.path}');
    //if (!hasModule(module.name)) {
    //registerModule(module);
    //}

    Get.to(
      () => DetalleScreen(
        module: module,
        object: object,
        canDelete: canDelete,
      ),
      id: dashboardKeyId,
    );
  }

  void pop() {
    Get.nestedKey(dashboardKeyId)?.currentState?.pop();
  }
}
