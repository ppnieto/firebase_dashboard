import 'package:firebase_dashboard/components/menu/menu_base.dart';
import 'package:firebase_dashboard/controllers/menu.dart';
import 'package:flutter/material.dart';

class MenuClick extends MenuBase {
  Function(BuildContext context) onClick;
  MenuClick(
      {required String label,
      required IconData iconData,
      required this.onClick})
      : super(label: label, iconData: iconData);

  @override
  Widget build(BuildContext context, DashboardMenuController menuController) {
    return Material(
      child: ListTile(
        onTap: () {
          onClick(context);
        },
        leading: Icon(iconData),
        title: Text(label, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
