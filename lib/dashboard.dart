library dashboard;

import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:flutter/material.dart';

final int responsiveDashboardWidth = 1000;

class DashboardMainScreen extends StatefulWidget {
  final List<MenuBase> menus;
  final List<Widget>? actions;
  final String title;
  final Function? getRolesFunction;
  final Widget? sideBar;
  final double sideBarWidth;
  final IconData? sideBarIcon;
  final DashboardTheme? theme;

  static DashboardTheme? dashboardTheme;

  DashboardMainScreen(
      {Key? key,
      required this.menus,
      this.actions,
      required this.title,
      this.getRolesFunction,
      this.sideBar,
      this.sideBarWidth = 100,
      this.theme,
      this.sideBarIcon = Icons.view_sidebar});

  @override
  DashboardMainScreenState createState() => DashboardMainScreenState();
}

class DashboardMainScreenState extends State<DashboardMainScreen> with SingleTickerProviderStateMixin {
  bool isSidebar = false;
  int active = 0;
  Widget currentWidget = SizedBox.shrink();
  bool isMenu = true;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    DashboardMainScreen.dashboardTheme = widget.theme;
  }

  void showScreen(Widget screen) {
    setState(() {
      currentWidget = screen;
    });
    _navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => screen,
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.theme?.appBar1BackgroundColor,
        leading: MediaQuery.of(context).size.width >= responsiveDashboardWidth
            ? IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  setState(() {
                    isMenu = !isMenu;
                  });
                },
              )
            : null,
        automaticallyImplyLeading: MediaQuery.of(context).size.width < responsiveDashboardWidth ? true : false,
        title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          Container(
            child: Text(
              widget.title, // + " - " + subtitle,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]),
        actions: widget.actions ??
            <Widget>[] +
                (widget.sideBar != null
                    ? [
                        IconButton(
                            icon: Icon(widget.sideBarIcon),
                            onPressed: () {
                              setState(() {
                                isSidebar = !isSidebar;
                              });
                            })
                      ]
                    : []),
      ),
      body: Row(
        children: <Widget>[
          MediaQuery.of(context).size.width < responsiveDashboardWidth || !isMenu
              ? Container()
              : Card(
                  elevation: 2.0,
                  child: Container(
                    color: widget.theme?.canvasColor,
                    margin: EdgeInsets.all(0),
                    height: MediaQuery.of(context).size.height,
                    width: 300,
                    child: listDrawerItems(context, false),
                  ),
                ),
          Expanded(
            child: Navigator(
                key: _navigatorKey,
                onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(builder: (_) => (widget.menus.first as Menu).child)),
          ),
          isSidebar ? Container(width: widget.sideBarWidth, child: widget.sideBar) : SizedBox.shrink(),
        ],
      ),
      drawer: Padding(padding: EdgeInsets.only(top: 56), child: Drawer(child: listDrawerItems(context, true))),
    );
  }

  Widget listDrawerItems(BuildContext context, bool drawerStatus) {
    var menus = widget.menus;
    return ListView(
        children: menus.map<Widget>((menu) {
      bool hasRole = true;

      if (menu.role != null) {
        List<String>? roles = widget.getRolesFunction != null ? widget.getRolesFunction!() : [];
        if (roles == null)
          hasRole = false;
        else
          hasRole = roles.contains(menu.role);
      }
      if (menu is MenuGroup) {
        return hasRole
            ? ExpansionTile(
                collapsedBackgroundColor: widget.theme?.menuBackgroundColor,
                backgroundColor: widget.theme?.menuBackgroundColor,
                initiallyExpanded: menu.open,
                childrenPadding: EdgeInsets.only(left: 24),
                iconColor: widget.theme?.menuTextColor,
                collapsedIconColor: widget.theme?.menuTextColor,
                title: Text(menu.label, style: TextStyle(fontSize: 18, color: widget.theme?.menuTextColor)),
                leading: Icon(menu.iconData, color: widget.theme?.menuTextColor),
                children: menu.children!.map<Widget>((submenu) {
                  Menu m = submenu as Menu;
                  bool isSelected = m.child.hashCode == currentWidget.hashCode;

                  return submenu.build(context, isSelected, widget.theme, () {
                    showScreen(m.child);

                    if (drawerStatus) Navigator.pop(context);
                  });
                }).toList())
            : Container();
      } else {
        Menu m = menu as Menu;
        bool isSelected = m.child.hashCode == currentWidget.hashCode;
        print(m.child.toString() + " is selected = $isSelected");
        return hasRole
            ? menu.build(context, isSelected, widget.theme, () {
                showScreen(m.child);
                if (drawerStatus) Navigator.pop(context);
              })
            : Container();
      }
    }).toList());
  }
}
