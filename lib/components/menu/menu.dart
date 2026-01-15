import 'package:firebase_dashboard/components/menu/menu_base.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/controllers/dashboard.dart';
import 'package:firebase_dashboard/controllers/menu.dart';
import 'package:firebase_dashboard/services/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Menu extends MenuBase {
  String? route;
  Future<Widget> Function(BuildContext)? builder;
  Menu({
    required String label,
    this.route,
    this.builder,
    IconData iconData = Icons.question_mark,
    String? role,
    required String id,
    bool? visible,
  }) : super(label: label, iconData: iconData, role: role, id: id, visible: visible);

  @override
  Widget build(BuildContext context, DashboardMenuController menuController) {
    bool selected = menuController.currentMenu?.id == id;
    return Material(
      child: ListTile(
        onTap: () {
          Get.log('onTap menu ($selected)');
          menuController.currentMenu = this;
          
          if (!selected) {
            DashboardUtils.findController<DashboardController>(context: context)?.showMenu(menuId: this.id!, context: context);
          }
          ScaffoldState? scaffoldState = context.findAncestorStateOfType<ScaffoldState>();
          if (scaffoldState != null) {
            if (scaffoldState.isDrawerOpen) {
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
