import 'package:firebase_dashboard/classes/dashboard_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class DashboardTheme extends StatelessWidget {
  final Widget child;
  final DashboardThemeData data;
  const DashboardTheme({super.key, required this.child, required this.data});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardThemeController>(
        init: Get.put<DashboardThemeController>(DashboardThemeController(data: data), permanent: true),
        builder: (context) {
          return child;
        });
  }
}

class DashboardThemeController extends GetxController {
  final DashboardThemeData data;

  static DashboardThemeController get to => Get.find<DashboardThemeController>();

  DashboardThemeController({required this.data});

  ThemeData get _themeData => Theme.of(Get.context!);

  Color get mainScaffoldBackgroundColor => data.mainScaffoldBackgroundColor ?? _themeData.scaffoldBackgroundColor;
  Color get secondaryScaffoldBackgroundColor => data.secondaryScaffoldBackgroundColor ?? _themeData.scaffoldBackgroundColor;
  Color? get mainScaffoldColor => data.mainScaffoldColor ?? _themeData.appBarTheme.foregroundColor;
  Color? get secondaryScaffoldColor => data.secondaryScaffoldColor ?? _themeData.appBarTheme.foregroundColor;
  Color get canvasColor => data.canvasColor ?? _themeData.canvasColor;
  Color get menuBackgroundColor => data.menuBackgroundColor ?? _themeData.canvasColor;
  Color get menuColor => data.menuColor ?? _themeData.primaryColor;
  Color get menuSelectedBackgroundColor => data.menuSelectedBackgroundColor ?? _themeData.primaryColor;
  Color get menuSelectedColor => data.menuSelectedColor ?? _themeData.canvasColor;

  Color get dataGridHeaderBackgroundColor => data.dataGridHeaderBackgroundColor ?? _themeData.secondaryHeaderColor;
  Color get dataGridHeaderColor => data.dataGridHeaderColor ?? _themeData.highlightColor;
  Color get dataGridCellBackgroundColor => data.dataGridCellBackgroundColor ?? _themeData.canvasColor;
  Color get dataGridCellColor => data.dataGridCellColor ?? _themeData.primaryColor;
  Color get dataGridCellColorWarn => data.dataGridCellColorWarn ?? _themeData.hintColor;
  Color get dataGridSelectedCellBackgroundColor => data.dataGridSelectedCellBackgroundColor ?? _themeData.primaryColor;
  Color get dataGridSelectedCellColor => data.dataGridSelectedCellColor ?? _themeData.canvasColor;

  Color get floatingButtonBackgroundColor => data.floatingButtonBackgroundColor ?? _themeData.canvasColor;
  Color get floatingButtonColor => data.floatingButtonColor ?? _themeData.primaryColor;
}
