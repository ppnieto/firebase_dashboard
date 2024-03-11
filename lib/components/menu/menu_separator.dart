import 'package:firebase_dashboard/components/menu/menu_base.dart';
import 'package:firebase_dashboard/controllers/menu.dart';
import 'package:flutter/material.dart';

class MenuSeparator extends MenuBase {
  MenuSeparator() : super(label: "", iconData: Icons.abc);

  @override
  Widget build(BuildContext context, DashboardMenuController menuController) {
    return Divider(thickness: 2, color: Theme.of(context).primaryColor);
  }
}
