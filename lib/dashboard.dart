library dashboard;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:flutter/material.dart';

final int responsiveDashboardWidth = 1000;

class DashboardMainScreen extends StatefulWidget {
  final List<MenuBase> menus;
  final List<Widget> actions;
  final String title;
  final DocumentSnapshot docUser;
  final Widget sideBar;
  final double sideBarWidth;
  DashboardMainScreen(
      {this.menus,
      this.actions,
      this.title,
      this.docUser,
      this.sideBar,
      this.sideBarWidth = 100});

  @override
  DashboardMainScreenState createState() => DashboardMainScreenState();
}

class DashboardMainScreenState extends State<DashboardMainScreen>
    with SingleTickerProviderStateMixin {
  bool isSidebar = false;
  TabController tabController;
  int active = 0;
  List<Widget> mainContents;
  Map<int, int> indexes = {};

  @override
  void initState() {
    super.initState();

    mainContents = getMainContents();

    tabController = new TabController(
        vsync: this, length: mainContents.length, initialIndex: 0)
      ..addListener(() {
        setState(() {
          active = tabController.index;
        });
      });
  }

  List<Widget> getMainContents() {
    List<Widget> result = [];

    addMenu(MenuBase menu) {
      if (menu is Menu) {
        // update idx
        indexes[menu.hashCode] = result.length;
        result.add(menu.child);
      }
      if (menu is MenuGroup) {
        for (var child in menu.children) {
          addMenu(child);
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

  getMenuItem(bool drawerStatus, String text, IconData iconData, int idx,
          bool ident) =>
      FlatButton(
        padding: EdgeInsets.only(left: ident ? 50 : 20),
        color: tabController.index == idx ? Colors.grey[100] : Colors.white,
        onPressed: () {
          tabController.animateTo(idx);
          drawerStatus ? Navigator.pop(context) : print("");
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
            child: Row(children: [
              Icon(iconData),
              SizedBox(
                width: 8,
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'HelveticaNeue',
                ),
              ),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            MediaQuery.of(context).size.width < responsiveDashboardWidth
                ? true
                : false,
        title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 32),
                child: Text(
                  widget.title,
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
                        icon: Icon(Icons.view_sidebar),
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
          MediaQuery.of(context).size.width < responsiveDashboardWidth
              ? Container()
              : Card(
                  elevation: 2.0,
                  child: Container(
                      margin: EdgeInsets.all(0),
                      height: MediaQuery.of(context).size.height,
                      width: 300,
                      color: Colors.white,
                      child: listDrawerItems(false)),
                ),
          Container(
            width: (MediaQuery.of(context).size.width < responsiveDashboardWidth
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width - 310) -
                (isSidebar ? widget.sideBarWidth : 0),
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: mainContents,
            ),
          ),
          isSidebar
              ? Container(width: widget.sideBarWidth, child: widget.sideBar)
              : SizedBox.shrink(),
        ],
      ),
      drawer: Padding(
          padding: EdgeInsets.only(top: 56),
          child: Drawer(child: listDrawerItems(true))),
    );
  }

  Widget listDrawerItemsOLD(bool drawerStatus) {
    return ListView(
        children: widget.menus.map<Widget>((menu) {
      int idx = widget.menus.indexOf(menu);
      return getMenuItem(drawerStatus, menu.label, menu.iconData, idx, false);
    }).toList());
  }

  Widget listDrawerItems(bool drawerStatus) {
    var menus = widget.menus;
    return ListView(
        children: menus.map<Widget>((menu) {
      bool hasRole = true;

      if (menu.role != null) {
        // si tiene restricción de rol
        if (widget.docUser != null &&
            widget.docUser.data().containsKey('roles') &&
            widget.docUser['roles'].contains(menu.role) == false)
          hasRole = false;
      }

      if (menu is Menu) {
        return hasRole
            ? getMenuItem(drawerStatus, menu.label, menu.iconData,
                indexes[menu.hashCode], false)
            : Container();
      }
      if (menu is MenuGroup) {
        return hasRole
            ? ExpansionTile(
                initiallyExpanded: true,
                title: Text(menu.label),
                leading: Icon(menu.iconData),
                children: menu.children.map<Widget>((submenu) {
                  return getMenuItem(drawerStatus, submenu.label,
                      submenu.iconData, indexes[submenu.hashCode], true);
                }).toList())
            : Container();
      }
      return Container();
    }).toList());
  }
}
