import 'package:flutter/material.dart';

class DashboardTheme {
  Color? appBar1BackgroundColor;
  Color? appBar2BackgroundColor;
  Color? appBar1TextColor;
  Color? appBar2TextColor;
  Color? menuBackgroundColor;
  Color? menuTextColor;
  Color? menuSelectedBackgroundColor;
  Color? menuSelectedTextColor;
  Color? canvasColor;
  Color? textColor;
  Color? iconButtonColor;

  DashboardTheme(
      {required BuildContext context,
      this.appBar1BackgroundColor,
      this.appBar2BackgroundColor,
      this.appBar1TextColor,
      this.appBar2TextColor,
      this.menuBackgroundColor,
      this.menuTextColor,
      this.menuSelectedBackgroundColor,
      this.menuSelectedTextColor,
      this.canvasColor,
      this.textColor,
      this.iconButtonColor}) {
    appBar1BackgroundColor ??= Theme.of(context).primaryColor;
    appBar2BackgroundColor ??= Theme.of(context).primaryColor;
    appBar1TextColor ??= Theme.of(context).primaryColor;
    appBar2TextColor ??= Theme.of(context).primaryColor;
    menuBackgroundColor ??= Theme.of(context).backgroundColor;
    menuTextColor ??= Theme.of(context).primaryColor;
    menuSelectedBackgroundColor ??= Theme.of(context).primaryColor;
    menuSelectedTextColor ??= Theme.of(context).canvasColor;
    canvasColor ??= Theme.of(context).canvasColor;
    textColor ??= Theme.of(context).primaryColor;
  }
}
