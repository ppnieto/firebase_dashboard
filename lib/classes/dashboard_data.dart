import 'package:firebase_dashboard/components/menu/menu_base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardData {
  final String id;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  List<MenuBase> menus;
  final List<GetPage> pages;
  final Function? getRolesFunction;

  DashboardData({required this.id, this.title, this.titleWidget, this.actions, this.menus = const [], required this.pages, this.getRolesFunction});
}
