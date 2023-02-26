import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/field_types/field_type_base.dart';
import 'package:firebase_dashboard/screens/admin.dart';
import 'package:firebase_dashboard/screens/admin.dart';
import 'package:firebase_dashboard/theme.dart';
import 'package:flutter/material.dart';

export 'field_types/field_type_base.dart';
export 'field_types/actions.dart';
export 'field_types/image_url.dart';
export 'field_types/location.dart';
export 'field_types/date.dart';
export 'field_types/double.dart';
export 'field_types/multiref.dart';
export 'field_types/ref.dart';
export 'field_types/inline_ref.dart';
export 'field_types/datetime.dart';
export 'field_types/spin.dart';
export 'field_types/boolean.dart';
export 'field_types/text.dart';
export 'field_types/ref_childs.dart';
export 'field_types/defecto.dart';
export 'field_types/subcollection.dart';
export 'field_types/memo.dart';
export 'field_types/qr.dart';
export 'field_types/rating.dart';
export 'field_types/select.dart';
export 'field_types/multi_select.dart';
export 'field_types/file.dart';
export 'field_types/link.dart';
export 'field_types/color.dart';
export 'field_types/async.dart';

export "package:firebase_dashboard/theme.dart";
export 'field_types/tags.dart';
export 'field_types/widget.dart';

class Module {
  final String name;
  final String title;
  //IconData icon;
  String? collection;
  final CollectionReference Function()? getCollection;
  final Query Function()? getQueryCollection;
  final List<DocumentSnapshot> Function(List<DocumentSnapshot>?)? doFilter;
  final String? orderBy;
  final Query Function(Query)? addFilter;
  final String? reverseOrderBy;
  final Future<bool> Function(bool, Map<String, dynamic>?)? onSave;
  final Function? onUpdated;
  final Function(DocumentSnapshot)? onRemove;
  final Function(Map<String, dynamic>?)? onNew;
  final bool globalSearch;
  final Future<String?> Function(bool isNew, Map<String, dynamic> updateData)?
      validation;
  final int rowsPerPage;
  final bool canSelect;
  final bool canAdd;
  final bool floatingButtons;
  final bool canEdit;
  final bool canRemove;
  int firstFreezedColumns;
  final bool deleteDisabled;
  final bool removeInEdit;
  final bool canSort;
  final Color Function(DocumentSnapshot)? backgroundColor;
  final bool exportExcel;
  final bool showColumnSelection;
  final bool compactColumnSelection;
  final double? actionColumnWidth;
  final bool fitColumns;
  final List<String> fieldsForShowInSearchResult;
  final List<Widget> Function(DocumentSnapshot object, BuildContext context)?
      getActions;
  final List<Widget> Function(BuildContext context)? getScaffoldActions;

  List<ColumnModule> columns;
  //List<ColumnModule> showingColumns = [];

  Module(
      {required this.name,
      this.collection,
      this.getCollection,
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
      this.fitColumns = false,
      //this.sortBy,
      //this.reverseSortBy,
      this.rowsPerPage = 100,
      this.canAdd = true,
      this.canEdit = true,
      this.canRemove = true,
      this.firstFreezedColumns = 0,
      this.removeInEdit = false,
      this.canSort = true,
      this.canSelect = false,
      this.deleteDisabled = false,
      this.floatingButtons = false,
      this.actionColumnWidth,
      this.backgroundColor,
      this.onSave,
      this.showColumnSelection = true,
      this.compactColumnSelection = true,
      this.onUpdated,
      this.onNew,
      this.onRemove,
      this.validation,
      this.getActions,
      this.fieldsForShowInSearchResult = const [],
      this.getScaffoldActions}) {
    //this.showingColumns = this.columns;
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
  double? width;
  bool showLabelOnEdit;
  bool canSort;
  bool visible;

  ColumnModule({
    required this.label,
    required this.field,
    required this.type,
    this.editable = true,
    this.listable = true,
    this.clickToDetail = true,
    this.filter = true,
    this.mandatory = false,
    this.showOnEdit = true,
    this.showLabelOnEdit = true,
    this.width,
    this.visible = true,
    this.showOnNew = true,
    this.excellable = true,
    this.canSort = true,
  });
}

abstract class MenuBase {
  String label;
  IconData iconData;
  String? role;
  String? id;
  bool? visible;

  MenuBase(
      {required this.label,
      required this.iconData,
      this.role,
      this.id,
      this.visible});

  @override
  int get hashCode {
    return label.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return super == other;
  }

  Widget build(BuildContext context, bool isSelected, DashboardTheme theme,
      Function press) {
    return Text("No implemetado para MenuBase");
  }
}

class Menu extends MenuBase {
  Function builder;

  Menu({
    required String label,
    required this.builder,
    IconData iconData = Icons.question_mark,
    String? role,
    String? id,
    bool? visible,
  }) : super(
            label: label,
            iconData: iconData,
            role: role,
            id: id,
            visible: visible);

  @override
  build(BuildContext context, bool isSelected, DashboardTheme? theme,
      Function press) {
    return InkWell(
      onTap: () => press(),
      child: Container(
        padding: EdgeInsets.only(left: 20),
        color: isSelected
            ? theme?.menuSelectedBackgroundColor
            : theme?.menuBackgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
            child: Row(children: [
              Icon(iconData,
                  color: isSelected
                      ? theme?.menuSelectedTextColor
                      : theme?.menuTextColor),
              SizedBox(
                width: 8,
              ),
              Text(
                label,
                style: TextStyle(
                    fontSize: 18,
                    color: isSelected
                        ? theme?.menuSelectedTextColor
                        : theme?.menuTextColor),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class MenuClick extends MenuBase {
  Function(BuildContext context) onClick;
  MenuClick(
      {required String label,
      required IconData iconData,
      required this.onClick})
      : super(label: label, iconData: iconData);
}

class MenuGroup extends MenuBase {
  final List<MenuBase>? children;
  final bool open;
  MenuGroup(
      {this.children,
      required String label,
      required IconData iconData,
      String? role,
      this.open = false})
      : super(label: label, iconData: iconData, role: role);
}

class MenuSeparator extends MenuBase {
  MenuSeparator() : super(label: "", iconData: Icons.abc);
}

class MenuInfo extends Menu {
  final Function info;

  MenuInfo(
      {required Future<Widget> Function(BuildContext) builder,
      required String label,
      required IconData iconData,
      String? role,
      bool? visible,
      required this.info,
      String? id})
      : super(
            label: label,
            iconData: iconData,
            role: role,
            builder: builder,
            id: id,
            visible: visible);

  @override
  build(BuildContext context, bool isSelected, DashboardTheme? theme,
      Function press) {
    bool ident = false;

    return InkWell(
      onTap: () {
        press();
      },
      child: Container(
        padding: EdgeInsets.only(left: ident ? 50 : 20),
        //color: isSelected ? Theme.of(context).highlightColor : Theme.of(context).backgroundColor,
        color: isSelected
            ? theme?.menuSelectedBackgroundColor
            : theme?.menuBackgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
            child: Row(children: [
              Icon(iconData,
                  color: isSelected
                      ? theme?.menuSelectedTextColor
                      : theme?.menuTextColor),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      fontSize: 18,
                      color: isSelected
                          ? theme?.menuSelectedTextColor
                          : theme?.menuTextColor),
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
