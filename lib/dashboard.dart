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
      this.sideBarIcon = Icons.view_sidebar}) {}

  @override
  DashboardMainScreenState createState() => DashboardMainScreenState();
}

class DashboardMainScreenState extends State<DashboardMainScreen> with SingleTickerProviderStateMixin {
  bool isSidebar = false;
  int active = 0;
  bool isMenu = true;
  final _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Widget currentWidget;

  @override
  void initState() {
    super.initState();
    currentWidget = (widget.menus.first as Menu).child;
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

  MenuBase? findMenu(String id) {
    Iterable<MenuBase>? itMenus = this.widget.menus.where((element) => element.id == id);
    if (itMenus.isNotEmpty) {
      return itMenus.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget drawerItems = listDrawerItems(context);
    return Scaffold(
      key: _scaffoldKey,
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
                    child: drawerItems,
                  ),
                ),
          Expanded(
            child: Navigator(key: _navigatorKey, onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(builder: (_) => currentWidget)),
          ),
          isSidebar ? Container(width: widget.sideBarWidth, child: widget.sideBar) : SizedBox.shrink(),
        ],
      ),
      drawer: Padding(padding: EdgeInsets.only(top: 56), child: Drawer(child: drawerItems)),
    );
  }

  Widget listDrawerItems(BuildContext context) {
    //var menus = widget.menus;
    return ListView(
        children: widget.menus.map<Widget>((menu) {
      bool hasRole = true;

      if (menu.role != null) {
        List<String>? roles = widget.getRolesFunction != null ? widget.getRolesFunction!() : [];
        if (roles == null)
          hasRole = false;
        else
          hasRole = roles.contains(menu.role);
      }
      return hasRole ? _MenuTile(menu: menu) : SizedBox.shrink();
    }).toList());
  }
}

class _MenuTile extends StatelessWidget {
  final MenuBase menu;
  const _MenuTile({Key? key, required this.menu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DashboardMainScreenState? parentState = context.findAncestorStateOfType<DashboardMainScreenState>();
    DashboardTheme? theme = parentState?.widget.theme;
    if (menu is Menu) {
      MenuInfo? menuInfo = menu is MenuInfo ? menu as MenuInfo : null;

      bool selected = (menu as Menu).child.hashCode == parentState!.currentWidget.hashCode;

      return Container(
        color: selected ? theme?.menuSelectedBackgroundColor : theme?.menuBackgroundColor,
        child: ListTile(
          trailing: menuInfo?.info(),
          onTap: () {
            if (!selected) parentState.showScreen((menu as Menu).child);
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
          collapsedBackgroundColor: theme?.menuBackgroundColor,
          backgroundColor: theme?.menuBackgroundColor,
          initiallyExpanded: (menu as MenuGroup).open,
          childrenPadding: EdgeInsets.only(left: 24),
          iconColor: theme?.menuTextColor,
          collapsedIconColor: theme?.menuTextColor,
          title: Text(menu.label, style: TextStyle(fontSize: 18, color: theme?.menuTextColor)),
          leading: Icon(menu.iconData, color: theme?.menuTextColor),
          children: (menu as MenuGroup).children!.map<Widget>((submenu) {
            Menu m = submenu as Menu;
            return _MenuTile(menu: m);
          }).toList());
    } else {
      return Text("ERROR");
    }
  }
}
