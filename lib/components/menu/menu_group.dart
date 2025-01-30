import 'package:firebase_dashboard/components/menu/menu_base.dart';
import 'package:firebase_dashboard/controllers/menu.dart';
import 'package:flutter/material.dart';

class MenuGroup extends MenuBase {
  final List<MenuBase>? children;
  final bool open;
  MenuGroup(
      {this.children,
      required String label,
      required IconData iconData,
      String? role,
      this.open = false})
      : super(label: label, iconData: iconData, role: role);

  @override
  Widget build(BuildContext context, DashboardMenuController menuController) {
    return ExpansionTile(
        initiallyExpanded: open,
        childrenPadding: EdgeInsets.only(left: 14),
        title: Text(label, style: TextStyle(fontSize: 18)),
        leading: Icon(iconData),
        children: children?.map<Widget>((submenu) {
              return submenu.build(context,menuController);
              // _MenuTile(menu: submenu);
            }).toList() ??
            []);
  }
}
