import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/controllers/menu.dart' as menuC;
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  bool isSidebar = false;
  int active = 0;
  bool _isMenu = true;
  //Rx<Widget> _currentWidget = const SizedBox.shrink().obs;
  final DashboardTheme? theme;
  List<MenuBase>? menus;
  //Rx<MenuBase>? currentMenu;
  static String? tag;

  DashboardController({this.menus, this.theme});

  bool get isMenu => _isMenu;
  set isMenu(i) {
    _isMenu = i;
    update();
  }

  @override
  void onInit() {
    super.onInit();

    //DashboardMainScreen.dashboardTheme = widget.theme;
    Get.put(menuC.MenuController());
    menuC.MenuController menuController = Get.find<menuC.MenuController>();

    if (menus != null && menus!.isNotEmpty) {
      if (menus!.first is Menu) {
        menuController.currentMenu = menus!.first;
      } else if (menus!.first is MenuGroup) {
        MenuGroup mg = menus!.first as MenuGroup;
        menuController.currentMenu = (mg.children!.first as Menu);
      }
    }
    if (menuController.currentMenu != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showScreen(menuController.currentMenu! as Menu);
      });
    }
  }

  void reload(List<MenuBase> newMenus) {
    print('reload menus ' + newMenus.length.toString());
    menus = newMenus;
    update();
  }

  Future<void> showScreen(Menu menu) async {
    Get.log('showScreen ${menu.label} - ${menu.id}');
    menuC.MenuController menuController = Get.find<menuC.MenuController>();

    menuController.currentMenu = menu;
    Widget widget = await menu.builder(Get.context);
    //Get.offAllNamed(menu.id!, id: DashboardMainScreen.dashboardKeyId, arguments: widget);
    Get.offAll(() => widget, id: DashboardMainScreen.dashboardKeyId, transition: Transition.noTransition);
    //update();
  }

  MenuBase? findMenu(String id) {
    Iterable<MenuBase>? itMenus = (this.menus ?? []).where((element) => element.id == id);
    if (itMenus.isNotEmpty) {
      return itMenus.first;
    }
    return null;
  }
}
