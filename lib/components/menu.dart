import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/controllers/dashboard.dart';
import 'package:firebase_dashboard/controllers/menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DashboardController dashboardController = Get.find<DashboardController>();
    if (dashboardController.menus == null) {
      return Center(
          child: Container(
        width: 80,
        height: 80,
        child: CircularProgressIndicator(),
      ));
    }
    return GetBuilder<MenuController>(builder: (controller) {
      return ListView(
          children: (dashboardController.menus ?? []).map<Widget>((menu) {
        bool hasRole = true;

        if (menu.role != null) {
          List<String>? roles = []; // getRolesFunction != null ? getRolesFunction!() : [];
          hasRole = roles.contains(menu.role);
        }
        bool visible = menu.visible ?? true;
        return (hasRole && visible) ? _MenuTile(menu: menu) : const SizedBox.shrink();
      }).toList());
    });
  }
}

class _MenuTile extends StatelessWidget {
  final MenuBase menu;
  const _MenuTile({Key? key, required this.menu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DashboardController controller = Get.find<DashboardController>();
    MenuController menuController = Get.find<MenuController>();
    DashboardTheme? theme = controller.theme;
    if (menu is Menu) {
      MenuInfo? menuInfo = menu is MenuInfo ? menu as MenuInfo : null;
      //bool selected = controller.isMenuSelected(menu as Menu);
      bool selected = menuController.currentMenu!.hashCode == menu.hashCode;
      return Container(
        color: selected ? theme?.menuSelectedBackgroundColor : theme?.menuBackgroundColor,
        child: ListTile(
          trailing: menuInfo?.info(),
          onTap: () {
            if (!selected) controller.showScreen(menu as Menu);
            ScaffoldState? scaffolsState = context.findAncestorStateOfType<ScaffoldState>();
            if (scaffolsState != null) {
              if (scaffolsState.isDrawerOpen) {
                Navigator.of(context).pop();
              }
            }
          },
          selected: selected,
          leading: Icon(menu.iconData, color: selected ? theme?.menuSelectedTextColor : theme?.menuTextColor),
          title: Text(
            menu.label,
            style: TextStyle(fontSize: 18, color: selected ? theme?.menuSelectedTextColor : theme?.menuTextColor),
          ),
        ),
      );
    } else if (menu is MenuGroup) {
      return ExpansionTile(
          initiallyExpanded: (menu as MenuGroup).open,
          childrenPadding: EdgeInsets.only(left: 24),
          collapsedBackgroundColor: theme?.menuBackgroundColor,
          backgroundColor: theme?.menuBackgroundColor,
          iconColor: theme?.menuTextColor,
          collapsedIconColor: theme?.menuTextColor,
          title: Text(menu.label, style: TextStyle(fontSize: 18, color: theme?.menuTextColor)),
          leading: Icon(menu.iconData, color: theme?.menuTextColor),
          children: (menu as MenuGroup).children!.map<Widget>((submenu) {
            return _MenuTile(menu: submenu);
          }).toList());
    } else if (menu is MenuClick) {
      MenuClick menuClick = menu as MenuClick;

      return Container(
          color: theme?.menuBackgroundColor,
          child: ListTile(
            onTap: () {
              menuClick.onClick(context);
            },
            leading: Icon(menu.iconData, color: theme?.menuTextColor),
            title: Text(menu.label, style: TextStyle(fontSize: 18, color: theme?.menuTextColor)),
          ));
    } else if (menu is MenuSeparator) {
      return Divider(thickness: 2, color: Theme.of(context).primaryColor);
    } else {
      return Text("ERROR");
    }
  }
}
