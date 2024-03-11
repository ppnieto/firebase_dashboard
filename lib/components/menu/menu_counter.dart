import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/components/menu/menu_info.dart';
import 'package:flutter/material.dart';

class MenuCounter extends MenuInfo {
  final Query? countQuery;
  final Query query;
  final int? limit;
  final bool fullQuery;
  Future<Widget> Function(BuildContext)? builder;

  final Color Function(int value)? getCounterBackgroundColor;
  final Color Function(int value)? getCounterForegroundColor;

  MenuCounter({
    required String label,
    super.route,
    required this.query,
    this.getCounterBackgroundColor,
    this.getCounterForegroundColor,
    this.limit,
    this.fullQuery = false,
    this.builder,
    this.countQuery,
    required IconData iconData,
    required String id,
  }) : super(
            label: label,
            iconData: iconData,
            info: (context) {
              return MenuCounterWidget(
                query: query,
                countQuery: countQuery,
                limit: limit,
                fullQuery: fullQuery,
                getCounterBackgroundColor: getCounterBackgroundColor,
                getCounterForegroundColor: getCounterForegroundColor,
              );
            },
            id: id);
}

class MenuCounterWidget extends StatefulWidget {
  final Query query;
  final int? limit;
  final Widget? child;
  final bool fullQuery;
  final Query? countQuery;
  final Color Function(int value)? getCounterBackgroundColor;
  final Color Function(int value)? getCounterForegroundColor;

  const MenuCounterWidget(
      {Key? key,
      required this.query,
      this.limit,
      this.fullQuery = false,
      this.getCounterBackgroundColor,
      this.getCounterForegroundColor,
      this.child,
      this.countQuery})
      : super(key: key);

  @override
  State<MenuCounterWidget> createState() => __MenuCounterState();
}

class __MenuCounterState extends State<MenuCounterWidget> {
  StreamSubscription<QuerySnapshot>? counterSubscription;
  int counter = -1;
  bool showPlus = false;

  @override
  void initState() {
    super.initState();
    print("_MenuCounter initState - limit ${widget.limit}");
    Query tmpQuery = widget.countQuery ?? widget.query;
    if (widget.limit != null) {
      tmpQuery = tmpQuery.limit(widget.limit!);
    }
    if (widget.fullQuery) {
      counterSubscription = tmpQuery.snapshots().listen((value) {
        setState(() {
          counter = value.docs.length;
          showPlus = widget.limit != null && counter == widget.limit;
        });
      });
    } else {
      tmpQuery.count().get().then((countQuery) {
        setState(() {
          counter = countQuery.count ?? 0;
          showPlus = widget.limit != null && counter == widget.limit;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    counterSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (counter < 0) {
      // inicializando
      return const SizedBox.shrink();
    }
    return Badge(
      label: Text("$counter${showPlus ? '+' : ''}"),
      backgroundColor: widget.getCounterBackgroundColor != null ? widget.getCounterBackgroundColor!(counter) : null,
      textColor: widget.getCounterForegroundColor != null ? widget.getCounterForegroundColor!(counter) : null,
      child: widget.child,
    );
  }
}
