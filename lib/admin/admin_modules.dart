import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/field_types/field_type_base.dart';
import 'package:firebase_dashboard/admin/screens/admin.dart';
import 'package:firebase_dashboard/theme.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

export "field_types/field_type_base.dart";
export "field_types/actions.dart";
export "field_types/image_url.dart";
export "field_types/location.dart";
export "field_types/date.dart";
export "field_types/double.dart";
export "field_types/multiref.dart";
export "field_types/ref.dart";
export "field_types/inline_ref.dart";
export "field_types/datetime.dart";
export "field_types/number.dart";
export "field_types/boolean.dart";
export "field_types/text.dart";
export "field_types/ref_childs.dart";
export "field_types/defecto.dart";
export "field_types/subcollection.dart";
export "field_types/memo.dart";
export "field_types/qr.dart";
export "field_types/rating.dart";
export "field_types/select.dart";
export 'field_types/multi_select.dart';
export 'field_types/file.dart';

export "package:firebase_dashboard/theme.dart";
export "field_types/tags.dart";
export "field_types/widget.dart";

class Module {
  final String name;
  final String title;
  //IconData icon;
  String? collection;
  final Function? getQueryCollection;
  final Function? doFilter;
  final String? orderBy;
  final Query Function(Query)? addFilter;
  final String? reverseOrderBy;
  final Function? onSave;
  final Function? onUpdated;
  final Function? onRemove;
  final Function? onNew;
  final bool globalSearch;
  final Future<String?> Function(bool isNew, Map<String, dynamic> updateData)? validation;
  final int rowsPerPage;
  final bool canSelect;
  final bool canAdd;
  final bool canEdit;
  final bool canRemove;
  final bool removeInEdit;
  final bool canSort;
  final bool exportExcel;
  final double? actionColumnWidth;
  final List<String> fieldsForShowInSearchResult;
  final List<Widget> Function(DocumentSnapshot object, BuildContext context)? getActions;
  final List<Widget> Function(BuildContext context, AdminScreenState state)? getScaffoldActions;

  List<ColumnModule> columns;
  //List<ColumnModule> get listableColumns => columns.where((col) => col.listable).toList();

  List<ColumnModule> showingColumns = [];

  Module(
      {required this.name,
      this.collection,
      this.getQueryCollection,
      this.addFilter,
      this.doFilter,
      required this.title,
//      required this.icon,
      required this.columns,
      this.globalSearch = false,
      this.orderBy,
      this.reverseOrderBy,
      this.exportExcel = true,
      //this.sortBy,
      //this.reverseSortBy,
      this.rowsPerPage = 10,
      this.canAdd = true,
      this.canEdit = true,
      this.canRemove = true,
      this.removeInEdit = false,
      this.canSort = true,
      this.canSelect = false,
      this.actionColumnWidth,
      this.onSave,
      this.onUpdated,
      this.onNew,
      this.onRemove,
      this.validation,
      this.getActions,
      this.fieldsForShowInSearchResult = const [],
      this.getScaffoldActions}) {
    this.showingColumns = this.columns;
  }
}

class ColumnModule {
  String label;
  String field;
  FieldType type;
  bool editable;
  bool showOnEdit;
  bool showOnNew;
  bool listable;
  bool excellable;
  bool clickToDetail;
  bool filter;
  bool mandatory;
  ColumnSize size;
  double? width;
  bool showLabelOnEdit;
  bool canSort;

  ColumnModule({
    required this.label,
    required this.field,
    required this.type,
    this.editable = true,
    this.listable = true,
    this.clickToDetail = true,
    this.filter = false,
    this.mandatory = false,
    this.showOnEdit = true,
    this.showLabelOnEdit = true,
    this.size = ColumnSize.M,
    this.width,
    this.showOnNew = true,
    this.excellable = true,
    this.canSort = true,
  });

  double getWidth() {
    const Map<ColumnSize, double> widths = {
      ColumnSize.S: 80,
      ColumnSize.M: 140,
      ColumnSize.L: 220,
    };
    return widths[this.size] ?? 80;
  }
}

abstract class MenuBase {
  String label;
  IconData iconData;
  String? role;
  String? id;
  MenuBase({required this.label, required this.iconData, this.role, this.id});

  @override
  int get hashCode {
    return label.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return super == other;
  }

  Widget build(BuildContext context, bool isSelected, DashboardTheme theme, Function press) {
    return Text("No implemetado para MenuBase");
  }
}

class Menu extends MenuBase {
  final Widget child;

  Menu({
    required this.child,
    required String label,
    required IconData iconData,
    String? role,
    String? id,
  }) : super(label: label, iconData: iconData, role: role, id: id);

  @override
  build(BuildContext context, bool isSelected, DashboardTheme? theme, Function press) {
    return InkWell(
      onTap: () => press(),
      child: Container(
        padding: EdgeInsets.only(left: 20),
        color: isSelected ? theme?.menuSelectedBackgroundColor : theme?.menuBackgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
            child: Row(children: [
              Icon(iconData, color: isSelected ? theme?.menuSelectedTextColor : theme?.menuTextColor),
              SizedBox(
                width: 8,
              ),
              Text(
                label,
                style: TextStyle(fontSize: 18, color: isSelected ? theme?.menuSelectedTextColor : theme?.menuTextColor),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class MenuGroup extends MenuBase {
  final List<MenuBase>? children;
  final bool open;
  MenuGroup({this.children, required String label, required IconData iconData, String? role, this.open = false})
      : super(label: label, iconData: iconData, role: role);
}

class MenuInfo extends Menu {
  final Widget child;
  final Function info;

  MenuInfo({required this.child, required String label, required IconData iconData, String? role, required this.info})
      : super(label: label, iconData: iconData, role: role, child: child);

  @override
  build(BuildContext context, bool isSelected, DashboardTheme? theme, Function press) {
    bool ident = false;

    return InkWell(
      onTap: () {
        press();
      },
      child: Container(
        padding: EdgeInsets.only(left: ident ? 50 : 20),
        //color: isSelected ? Theme.of(context).highlightColor : Theme.of(context).backgroundColor,
        color: isSelected ? theme?.menuSelectedBackgroundColor : theme?.menuBackgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
            child: Row(children: [
              Icon(iconData, color: isSelected ? theme?.menuSelectedTextColor : theme?.menuTextColor),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 18, color: isSelected ? theme?.menuSelectedTextColor : theme?.menuTextColor),
                ),
              ),
              this.info()
            ]),
          ),
        ),
      ),
    );
  }
}
