import 'package:example/listado1.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DashboardMainScreen(
      title: "Dashboard demo",
      menus: [
        Menu(
          label: "Listado1",
          iconData: Icons.access_alarm,
          child: Listado1Screen(),
        ),
        Menu(
          label: "Listado2",
          iconData: Icons.add_business_rounded,
          child: Listado1Screen(),
        )
      ],
    );
  }
}
