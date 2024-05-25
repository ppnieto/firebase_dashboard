import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/controllers/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AdminActionButton extends StatelessWidget {
  final String title;
  final IconData iconData;
  final String? badge;
  final void Function() onClick;
  const AdminActionButton(
      {super.key,
      required this.title,
      required this.iconData,
      this.badge,
      required this.onClick});

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(iconData);
    if (badge != null) {
      icon = Badge(label: Text(badge!), child: icon);
    }

    if (AdminController.buttonAction == ButtonAction.Large) {
      return OutlinedButton.icon(
          icon: icon, label: Text(title), onPressed: onClick);
    } else {
      return IconButton(icon: icon, onPressed: onClick, tooltip: title);
    }
  }
}
