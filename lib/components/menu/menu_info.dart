import 'package:firebase_dashboard/classes/dashboard_theme.dart';
import 'package:firebase_dashboard/controllers/menu.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuInfo extends Menu {
  final Function(BuildContext context) info;

  MenuInfo({required String label, required IconData iconData, String? role, bool? visible, super.route, required this.info, required String id})
      : super(label: label, iconData: iconData, role: role, id: id, visible: visible);

  @override
  Widget build(BuildContext context, DashboardMenuController menuController) {
    bool selected = menuController.currentMenu?.id == id;
    return Material(
      child: ListTile(
        trailing: info(context),
        onTap: () {
          Get.log('onTap menu');
          menuController.currentMenu = this;
          if (!selected) DashboardUtils.findController<DashboardController>(context:context)?.showScreen(context: context, menu: this);
          ScaffoldState? scaffolsState = context.findAncestorStateOfType<ScaffoldState>();
          if (scaffolsState != null) {
            if (scaffolsState.isDrawerOpen) {
              Navigator.of(context).pop();
            }
          }
        },
        selected: selected,
        leading: Icon(iconData),
        title: Text(label,
            style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
