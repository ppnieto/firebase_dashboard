import 'package:firebase_dashboard/controllers/menu.dart';
import 'package:flutter/material.dart';

abstract class MenuBase {
  String label;
  IconData iconData;
  String? role;
  String? id;
  bool? visible;

  MenuBase({required this.label, required this.iconData, this.role, this.id, this.visible});

  @override
  int get hashCode {
    return label.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return super == other;
  }

  Widget build(BuildContext context, DashboardMenuController menuController) {
    return Text("No implemetado para MenuBase");
  }
}
