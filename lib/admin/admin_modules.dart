import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/field_types/field_type_base.dart';
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
export "field_types/memo.dart";
export "field_types/qr.dart";
export "field_types/rating.dart";
export "field_types/select.dart";
export "field_types/tags.dart";

class Module {
  final String name;
  final String title;
  //IconData icon;
  final String? collection;
  final Function? getQueryCollection;
  final Function? doFilter;
  final String? orderBy;
  final Function? addFilter;
  final String? reverseOrderBy;
  final Function? onSave;
  final Function? onUpdated;
  final Function? onRemove;
  final bool globalSearch;
  final Future<String?> Function(bool isNew, Map<String, dynamic> updateData)? validation;
  final int rowsPerPage;
  final bool canAdd;
  final bool canEdit;
  final bool canRemove;
  final bool canSort;
  final bool exportExcel;
  final List<Widget> Function(DocumentSnapshot object, BuildContext context)? getActions;

  List<ColumnModule> columns;
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
      this.canSort = false,
      this.onSave,
      this.onUpdated,
      this.onRemove,
      this.validation,
      this.getActions});
}

class ColumnModule {
  String label;
  String field;
  FieldType type;
  bool editable;
  bool showOnEdit;
  bool showOnNew;
  bool listable;
  bool clickToDetail;
  bool filter;
  bool mandatory;
  ColumnSize size;
  bool showLabelOnEdit;

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
    this.showOnNew = true,
  });

  getListContent(DocumentSnapshot _object) => type.getListContent(_object, this);
  getEditContent(DocumentSnapshot _object, Map<String, dynamic> values, ColumnModule column, Function onChange) {
    print("get edit content 2 . type = $type");
    return type.getEditContent(_object, values, column, onChange);
  }

  getFilterContent(value, Function onFilter) => type.getFilterContent(value, this, onFilter);
  getStringContent(DocumentSnapshot _object) => type.getStringContent(_object, this);
}

abstract class MenuBase {
  String label;
  IconData iconData;
  String? role;
  //int idx;
  MenuBase({required this.label, required this.iconData, this.role});

  @override
  int get hashCode {
    return label.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return super == other;
  }

  Widget build(BuildContext context, bool isSelected, Function press) {
    return Text("No implemetado para MenuBase");
  }
}

class Menu extends MenuBase {
  Widget child;

  Menu({
    required this.child,
    required String label,
    required IconData iconData,
    String? role,
  }) : super(label: label, iconData: iconData, role: role);

  @override
  build(BuildContext context, bool isSelected, Function press) {
    bool ident = false;

    return InkWell(
      onTap: () => press(),
      child: Container(
        padding: EdgeInsets.only(left: ident ? 50 : 20),
        color: isSelected ? Theme.of(context).highlightColor : Theme.of(context).backgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
            child: Row(children: [
              Icon(iconData, color: isSelected ? Theme.of(context).canvasColor : Theme.of(context).primaryColor),
              SizedBox(
                width: 8,
              ),
              Text(
                label,
                style: TextStyle(fontSize: 18, color: isSelected ? Theme.of(context).canvasColor : Theme.of(context).primaryColor),
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
  build(BuildContext context, bool isSelected, Function press) {
    bool ident = false;

    return InkWell(
      onTap: () {
        press();
      },
      child: Container(
        padding: EdgeInsets.only(left: ident ? 50 : 20),
        color: isSelected ? Theme.of(context).highlightColor : Theme.of(context).backgroundColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(top: 22, bottom: 22, right: 22),
            child: Row(children: [
              Icon(iconData, color: isSelected ? Theme.of(context).canvasColor : Theme.of(context).highlightColor),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 18, color: isSelected ? Theme.of(context).canvasColor : Theme.of(context).highlightColor),
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
