import 'package:example/listado2.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Listado1Screen extends StatelessWidget {
  @override
  build(BuildContext context) {
    return GetBuilder<Listado1Controller>(
        init: Listado1Controller(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(title: Text("Listado 1")),
            body: Center(
                child: ElevatedButton(
              child: Text("goto 2 ${controller.i}"),
              onPressed: () {
                controller.increment();
                //DashboardUtils.navigate('/listado2');
              },
            )),
          );
        });
  }
}

class Listado1Controller extends GetxController {
  int i = 0;

  void increment() {
    i++;
    update();
  }
}
