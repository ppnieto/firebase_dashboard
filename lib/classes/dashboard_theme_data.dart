import 'package:flutter/material.dart';

class DashboardThemeData {
  final Color? mainScaffoldBackgroundColor;
  final Color? secondaryScaffoldBackgroundColor;
  final Color? mainScaffoldColor;
  final Color? secondaryScaffoldColor;
  final Color? canvasColor;
  final Color? menuBackgroundColor;
  final Color? menuColor;
  final Color? menuSelectedBackgroundColor;
  final Color? menuSelectedColor;

  final Color? dataGridHeaderBackgroundColor;
  final Color? dataGridHeaderColor;
  final Color? dataGridCellBackgroundColor;
  final Color? dataGridCellColor;
  final Color? dataGridCellColorWarn;
  final Color? dataGridSelectedCellBackgroundColor;
  final Color? dataGridSelectedCellColor;

  final Color? floatingButtonBackgroundColor;
  final Color? floatingButtonColor;

  DashboardThemeData(
      {this.mainScaffoldBackgroundColor,
      this.secondaryScaffoldBackgroundColor,
      this.mainScaffoldColor,
      this.secondaryScaffoldColor,
      this.canvasColor,
      this.menuBackgroundColor,
      this.menuColor,
      this.menuSelectedBackgroundColor,
      this.menuSelectedColor,
      this.dataGridHeaderBackgroundColor,
      this.dataGridHeaderColor,
      this.dataGridCellBackgroundColor,
      this.dataGridCellColor,
      this.dataGridCellColorWarn,
      this.dataGridSelectedCellBackgroundColor,
      this.dataGridSelectedCellColor,
      this.floatingButtonBackgroundColor,
      this.floatingButtonColor});
}
