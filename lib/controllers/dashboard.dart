import 'package:firebase_dashboard/classes/dashboard_data.dart';
import 'package:firebase_dashboard/components/menu/menu_base.dart';
import 'package:firebase_dashboard/components/menu/menu_group.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/controllers/menu.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  DashboardData data;
  bool _isMenu = true;

  static final int idNestedNavigation = 100;

  DashboardController({required this.data});

  bool get isMenu => _isMenu;
  set isMenu(i) {
    _isMenu = i;
    update();
  }

  void reload(List<MenuBase> newMenus) {
    data.menus = newMenus;
    update();
  }

  Future<void> showScreen({required BuildContext context, required Menu menu, bool offAll = true}) async {
    Get.log('showScreen ${menu.label} - ${menu.id} - ${menu.route}');

    if (menu.route != null) {
      if (offAll) {
        Get.offAllNamed(menu.route!, id: DashboardController.idNestedNavigation);
      } else {
        Get.toNamed(menu.route!, id: DashboardController.idNestedNavigation, preventDuplicates: true);
      }
    } else if (menu.builder != null) {
      Widget widget = await menu.builder!(context);
      if (offAll) {
        Get.offAll(() => widget, id: DashboardController.idNestedNavigation);
      } else {
        Get.to(() => widget, id: DashboardController.idNestedNavigation, preventDuplicates: true);
      }
    } else {
      throw new Exception("Menu ${menu.id} no tiene route o builder");
    }
  }

  void showMenu({required String menuId, bool offAll = true, required BuildContext context}) {
    Get.log('showMenu ${menuId} ${data.id}');
    MenuBase? menu = findMenu(id: menuId);
    if (menu != null) {
      if (menu is Menu) {
        showScreen(context: context, menu: menu, offAll: offAll);
      }
    } else {
      throw new Exception("No puedo encontrar menu " + menuId);
    }
  }

  MenuBase? findMenu({required String id, MenuGroup? group}) {
    //Iterable<MenuBase>? itMenus = data.menus.where((element) => element.id == id);
    List<MenuBase> menus = group != null ? group.children! : data.menus;

    for (var menu in menus) {
      if (menu.id == id) return menu;
      if (menu is MenuGroup) {
        MenuBase? find = findMenu(id: id, group: menu);
        if (find != null) return find;
      }
    }
    return null;
  }
}
