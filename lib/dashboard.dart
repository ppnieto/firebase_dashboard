library dashboard;

import 'package:dashboard/admin/admin_modules.dart';
import 'package:dashboard/theme.dart';
import 'package:flutter/material.dart';

final int responsiveDashboardWidth = 1000;

class DashboardMainScreen extends StatefulWidget {
  final List<MenuBase> menus;
  final List<Widget> actions;
  final String title;
  final Function? getRolesFunction;
  final Widget? sideBar;
  final double sideBarWidth;
  final IconData? sideBarIcon;
  final DashboardTheme theme;
  static DashboardTheme? dashboardTheme;

  DashboardMainScreen(
      {required this.menus,
      required this.actions,
      required this.title,
      this.getRolesFunction,
      this.sideBar,
      this.sideBarWidth = 100,
      required this.theme,
      this.sideBarIcon = Icons.view_sidebar});

  @override
  DashboardMainScreenState createState() => DashboardMainScreenState();
}

class DashboardMainScreenState extends State<DashboardMainScreen> with SingleTickerProviderStateMixin {
  bool isSidebar = false;
  late TabController tabController;
  int active = 0;
  late List<Widget> mainContents;
  Map<int, int> indexes = {};
  int initialIndex = 0;
  bool isMenu = true;
//  String subtitle = "";

  @override
  void initState() {
    super.initState();

    DashboardMainScreen.dashboardTheme = widget.theme;

    mainContents = getMainContents();

    tabController = new TabController(vsync: this, length: mainContents.length, initialIndex: initialIndex)
      ..addListener(() {
        setState(() {
          active = tabController.index;
        });
      });
  }

  List<Widget> getMainContents() {
    List<Widget> result = [];

    addMenu(MenuBase menu) {
      bool hasRole = true;
      List<String>? roles = [];
      if (menu.role != null) {
        // si tiene restricción de rol
        if (widget.getRolesFunction != null) {
          roles = widget.getRolesFunction!();
        } else {
          print("error, no hay definido getRolesFunction");
        }

        if (roles == null || roles.isEmpty)
          hasRole = false;
        else if (roles.contains(menu.role) == false) hasRole = false;
      }
      if (hasRole) {
        if (menu is Menu) {
          // update idx
          indexes[menu.hashCode] = result.length;
          result.add(menu.child);
        }
        if (menu is MenuGroup) {
          for (var child in menu.children ?? []) {
            addMenu(child);
          }
        }
      }
    }

    for (final menu in widget.menus) {
      addMenu(menu);
    }
    return result;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.theme.appBar1BackgroundColor!,
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
            //margin: EdgeInsets.only(left: 32),
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
        actions: widget.actions +
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
                    color: widget.theme.canvasColor,
                    margin: EdgeInsets.all(0),
                    height: MediaQuery.of(context).size.height,
                    width: 300,
                    child: listDrawerItems(context, false),
                  ),
                ),
          Container(
            width: (MediaQuery.of(context).size.width < responsiveDashboardWidth || !isMenu
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width - 310) -
                (isSidebar ? widget.sideBarWidth : 0),
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: mainContents,
            ),
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
        //print("  menu.role = ${menu.role}");
        // si tiene restricción de rol
        List<String>? roles = widget.getRolesFunction != null ? widget.getRolesFunction!() : [];
        //print("   lista de roles -> $roles");
        if (roles == null)
          hasRole = false;
        else
          hasRole = roles.contains(menu.role);
      }
      //print("hasRole = $hasRole");
      bool isSelected = tabController.index == indexes[menu.hashCode];
      if (menu is MenuGroup) {
        return hasRole
            ? ExpansionTile(
                collapsedBackgroundColor: widget.theme.menuBackgroundColor,
                backgroundColor: widget.theme.menuBackgroundColor,
                initiallyExpanded: menu.open,
                childrenPadding: EdgeInsets.only(left: 24),
                iconColor: widget.theme.menuTextColor,
                collapsedIconColor: widget.theme.menuTextColor,
                title: Text(menu.label, style: TextStyle(fontSize: 18, color: widget.theme.menuTextColor)),
                leading: Icon(menu.iconData, color: widget.theme.menuTextColor),
                children: menu.children!.map<Widget>((submenu) {
                  bool isSelected = tabController.index == indexes[submenu.hashCode];
                  return submenu.build(context, isSelected, widget.theme, () {
                    tabController.animateTo(indexes[submenu.hashCode]!);
                    if (drawerStatus) Navigator.pop(context);
                  });
                }).toList())
            : Container();
      } else {
        return hasRole
            ? menu.build(context, isSelected, widget.theme, () {
                print("animateTo...");

                tabController.animateTo(indexes[menu.hashCode]!);
                if (drawerStatus) Navigator.pop(context);
/*
                setState(() {
                  subtitle = menu.label;
                });
                */
              })
            : Container();
      }
    }).toList());
  }
}
