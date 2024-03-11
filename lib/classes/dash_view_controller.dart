import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
abstract class DashView<Controller> extends GetView<Controller> {
  DashView({Key? key}) : super(key: key);
  GetxController createController();

  
}
*/

//abstract class DashController<View extends DashView> extends GetxController {}
/*
abstract class DashView<Controller> extends StatefulWidget {
  DashView({Key? key}) : super(key: key);

  State<DashView> createController();

  Widget build(BuildContext context, Controller controller);

  @override
  State<DashView> createState() => createController();
}

abstract class DashController<View extends StatefulWidget> extends State<View> {
  @override
  build(BuildContext context) {
    return (widget as DashView).build(context, this);
  }

  @override
  initState() {
    super.initState();
    // registramos el controlador por si lo buscamos fuera del árbol
    DashboardService.instance.registerController(this);
    onInit();
  }

  @override
  void dispose() {
    super.dispose();
    onClose();
    DashboardService.instance.unregisterController(this);
  }

  void onInit() {
    Get.log("onInit " + this.runtimeType.toString());
  }

  void onClose() {
    Get.log("onClose " + this.runtimeType.toString());
  }

  update() {
    if (mounted) {
      setState(() {});
    }
  }
}
*/