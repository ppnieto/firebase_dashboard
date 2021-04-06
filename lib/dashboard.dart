library dashboard;

import 'package:dashboard/admin/model/admin_modules.dart';
import 'package:flutter/material.dart';

final int responsiveDashboardWidth = 1000;

class DashboardMainScreen extends StatefulWidget {
  final List<Menu> menus;
  final List<Widget> actions;
  final String title;
  DashboardMainScreen({this.menus, this.actions, this.title});

  @override
  DashboardMainScreenState createState() => DashboardMainScreenState();
}

class DashboardMainScreenState extends State<DashboardMainScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  int active = 0;
  List<Widget> mainContents;

  @override
  void initState() {
    super.initState();
    mainContents = widget.menus.map((menu) => menu.child).toList();
    tabController = new TabController(
        vsync: this, length: mainContents.length, initialIndex: 0)
      ..addListener(() {
        setState(() {
          active = tabController.index;
        });
      });
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
                    fontFamily: 'HelveticaNeue',
                  ),
                ),
              ),
            ]),
        actions: widget.actions,
        //backgroundColor: ColorConstants.blue,
        // automaticallyImplyLeading: false,
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
            width: MediaQuery.of(context).size.width < responsiveDashboardWidth
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width - 310,
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: mainContents,
            ),
          )
        ],
      ),
      drawer: Padding(
          padding: EdgeInsets.only(top: 56),
          child: Drawer(child: listDrawerItems(true))),
    );
  }

  Widget listDrawerItems(bool drawerStatus) {
    return ListView(
        children: widget.menus.map<Widget>((menu) {
      int idx = widget.menus.indexOf(menu);
      return getMenuItem(drawerStatus, menu.label, menu.iconData, idx, false);
    }).toList());
  }
}
