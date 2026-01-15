import 'package:example/routes.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final DashboardData data = DashboardData(
      id: "sample_dashboard",
      title: "Ejemplo dashboard",
      actions: [],
      pages: Routes.pages.first.children,
      menus: [
        Menu(label: "Ejemplo1", iconData: Icons.kayaking, route: Routes.LISTADO_1, id: Routes.LISTADO_1),
        Menu(label: "Ejemplo2", iconData: Icons.g_mobiledata, route: Routes.LISTADO_2, id: Routes.LISTADO_2),
        Menu(label: "Ejemplo3", iconData: Icons.table_bar, route: Routes.LISTADO_3, id: Routes.LISTADO_3),
      ]);

  @override
  Widget build(BuildContext context) {
    return DashboardMainScreen(data: data);
  }
}
