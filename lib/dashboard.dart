library dashboard;

import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/components/menu.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/controllers/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final int responsiveDashboardWidth = 1000;

class DashboardMainScreen extends StatelessWidget {
  final List<MenuBase> menus;
  final List<Widget>? actions;
  final String? title;
  final Widget? titleWidget;
  final Widget? sideBar;
  final double sideBarWidth;
  final IconData? sideBarIcon;
  final DashboardTheme? theme;
  static DashboardTheme? dashboardTheme;

  static int dashboardKeyId = 100;

  DashboardMainScreen(
      {Key? key,
      required this.menus,
      this.actions,
      this.title,
      this.titleWidget,
      this.sideBar,
      this.sideBarWidth = 100,
      this.theme,
      this.sideBarIcon = Icons.view_sidebar}) {
    Get.put(DashboardController(menus: menus, theme: theme));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      Get.log('dashboard build');
      //Widget drawerItems = listDrawerItems(context);
      return Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor: theme?.canvasColor ?? Theme.of(context).canvasColor,
          highlightColor: DashboardMainScreen.dashboardTheme?.iconButtonColor,
          primaryColor: DashboardMainScreen.dashboardTheme?.appBar2BackgroundColor ?? Theme.of(context).secondaryHeaderColor,
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: theme?.appBar1BackgroundColor,
            leading: MediaQuery.of(context).size.width >= responsiveDashboardWidth
                ? IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      controller.isMenu = !controller.isMenu;
                    },
                  )
                : null,
            automaticallyImplyLeading: MediaQuery.of(context).size.width < responsiveDashboardWidth ? true : false,
            title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
              if (title != null)
                Container(
                  child: Text(
                    title!, // + " - " + subtitle,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (titleWidget != null) titleWidget!
            ]),
            actions: (actions ?? []) +
                (sideBar != null
                    ? [
                        IconButton(
                            icon: Icon(sideBarIcon),
                            onPressed: () {
                              /*
                            setState(() {
                              isSidebar = !isSidebar;
                            });
                            */
                            })
                      ]
                    : []),
          ),
          body: Row(
            children: <Widget>[
              MediaQuery.of(context).size.width < responsiveDashboardWidth || !controller.isMenu
                  ? Container()
                  : Container(
                      color: theme?.menuBackgroundColor,
                      child: Card(
                        elevation: 2.0,
                        child: Container(
                          color: theme?.menuBackgroundColor,
                          margin: EdgeInsets.all(0),
                          height: MediaQuery.of(context).size.height,
                          width: 300,
                          child: MenuDrawer(),
                        ),
                      ),
                    ),
              Expanded(
                child: Navigator(
                    key: Get.nestedKey(dashboardKeyId),
                    onGenerateRoute: (RouteSettings settings) {
                      print("onGenerateRoute ${settings.name}");
                      //MenuBase menu = menus.firstWhere((element) => element.id == settings.name);
                      if (settings.arguments != null) {
                        Widget widget = settings.arguments as Widget;
                        return MaterialPageRoute(builder: (_) => widget);
                      } else {
                        return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
                      }
                    }),
              ),
              controller.isSidebar ? Container(width: sideBarWidth, child: sideBar) : SizedBox.shrink(),
            ],
          ),
          drawer: Padding(padding: EdgeInsets.only(top: 56), child: Drawer(child: MenuDrawer())),
        ),
      );
    });
  }
}
