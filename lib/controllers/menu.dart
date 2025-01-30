import 'package:firebase_dashboard/components/menu/menu_base.dart';
import 'package:firebase_dashboard/components/menu_drawer.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardMenuController extends GetxController {
  MenuBase? _currentMenu;

  MenuBase? get currentMenu => _currentMenu;
  set currentMenu(MenuBase? mb) {
    print("set current menu ${mb?.id}");
    _currentMenu = mb;
    update();
  }
}
