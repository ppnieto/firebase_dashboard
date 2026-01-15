import 'package:firebase_dashboard/classes/dashboard_theme.dart';
import 'package:firebase_dashboard/components/menu_drawer.dart';
import 'package:firebase_dashboard/controllers/dashboard.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final int responsiveDashboardWidth = 1000;

class DashboardMainScreen extends StatelessWidget {
  final DashboardData data;
  final double sideBarWidth;
  DashboardMainScreen({super.key, required this.data, this.sideBarWidth = 100});

  GetPageRoute? getPageRoute(RouteSettings settings, GetPage page) {
    if (settings.name?.startsWith(page.name) ?? false) {
      Get.routing.args = settings.arguments;
      return GetPageRoute(
        page: () => page.page(),
        settings: settings,
      );
    }
    for (var child in page.children) {
      var pageRoute = getPageRoute(settings, child);
      if (pageRoute != null) return pageRoute;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
        init: DashboardController(data: data),
        global: false,
        builder: (controller) {
          // getx hack
          /*
          Get.log(
              "dashboardController::build (${controller.data.menus.length} - ${data.menus.length}})");              
          if (controller.data.menus.length != data.menus.length) {
            controller = DashboardController(data: data);
            Get.put(controller);
          }
          */

          return Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: AppBarTheme(
                backgroundColor: DashboardThemeController.to.mainScaffoldBackgroundColor,
                foregroundColor: DashboardThemeController.to.mainScaffoldColor,
              ),
            ),
            child: Scaffold(
              appBar: getAppBar(context, controller),
              drawer: Padding(padding: EdgeInsets.only(top: 56), child: Drawer(child: DashboardMenuDrawer())),
              body: Row(
                children: <Widget>[
                  MediaQuery.of(context).size.width < responsiveDashboardWidth || !controller.isMenu
                      ? Container()
                      : Container(
                          child: Card(
                            elevation: 2.0,
                            child: Container(
                              margin: EdgeInsets.all(0),
                              height: MediaQuery.of(context).size.height,
                              width: 300,
                              child: DashboardMenuDrawer(),
                            ),
                          ),
                        ),
                  Theme(
                    data: Theme.of(context).copyWith(
                        iconButtonTheme: IconButtonThemeData(
                            style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(DashboardThemeController.to.secondaryScaffoldColor))),
                        appBarTheme: AppBarTheme(
                            backgroundColor: DashboardThemeController.to.secondaryScaffoldBackgroundColor,
                            foregroundColor: DashboardThemeController.to.secondaryScaffoldColor,
                            iconTheme: IconThemeData(color: DashboardThemeController.to.secondaryScaffoldColor))),
                    child: Expanded(
                      child: Navigator(
                        key: Get.nestedKey(DashboardController.idNestedNavigation),
                        onGenerateRoute: (settings) {
                          for (var page in data.pages) {
                            var pageRoute = getPageRoute(settings, page);
                            if (pageRoute != null) return pageRoute;
                          }
                          return GetPageRoute(page: () => const SizedBox.shrink());
                        },
                      ),
                    ),
                  ),
                  //controller.isSidebar ? Container(width: sideBarWidth, child: widget.sideBar) : SizedBox.shrink(),
                ],
              ),
            ),
          );
        });

    //});
    /*}),
    );*/
  }

  getAppBar(BuildContext context, DashboardController controller) {
    return AppBar(
      leading: MediaQuery.of(context).size.width >= responsiveDashboardWidth
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                controller.isMenu = !controller.isMenu;
              },
            )
          : null,
      automaticallyImplyLeading: MediaQuery.of(context).size.width < responsiveDashboardWidth ? true : false,
      //backgroundColor: Theme.of(context).primaryColorDark,
      title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
        if (controller.data.title != null)
          Expanded(
            child: Text(
              controller.data.title!, // + " - " + subtitle,
              style: TextStyle(
                fontSize: 24,
                color: DashboardThemeController.to.mainScaffoldColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (controller.data.titleWidget != null) controller.data.titleWidget!
      ]),
      actions: (controller.data.actions ??
          []) /*+
            (data.sideBar != null
                ? [
                    IconButton(
                        icon: Icon(data.sideBarIcon),
                        onPressed: () {
               
                        })
                  ]
                : [])*/
      ,
    );
  }
}
