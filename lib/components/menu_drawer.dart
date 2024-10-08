import 'package:firebase_dashboard/controllers/dashboard.dart';
import 'package:firebase_dashboard/controllers/menu.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardMenuDrawer extends StatelessWidget {
  DashboardMenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("rebuild dashboard menu drawer");
    DashboardController? dashboardController =
        DashboardUtils.findController<DashboardController>(context:context);

    if (dashboardController == null) {
      return Text("No encuentro dashboard controller (last)");
    }
    return GetBuilder<DashboardMenuController>(
        initState: (state) {},
        init: DashboardMenuController(),
        global: false,
        builder: (controller) {
          return ListView(
              children: dashboardController.data.menus.map<Widget>((menu) {
            bool hasRole = true;

            if (menu.role != null) {
              Function? getRolesFunction =
                  DashboardUtils.findController<DashboardController>(context:context)
                      ?.data
                      .getRolesFunction;
              //Get.log('getRolesFunction: ${getRolesFunction}');
              List<String> roles =
                  getRolesFunction != null ? getRolesFunction() : [];
              hasRole = roles.contains(menu.role);
            }
            bool visible = menu.visible ?? true;
            return (hasRole && visible)
                ? menu.build(context, controller) /* _MenuTile(menu: menu)*/
                : const SizedBox.shrink();
          }).toList());
        });
  }
}
