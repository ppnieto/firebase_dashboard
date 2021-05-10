import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/model/field_types/field_type_base.dart';
import 'package:flutter/material.dart';

export "field_types/field_type_base.dart";
export "field_types/actions.dart";
export "field_types/image_url.dart";
export "field_types/location.dart";
export "field_types/date.dart";
export "field_types/currency.dart";
export "field_types/ref.dart";
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

class Module {
  String name;
  String title;
  IconData icon;
  String collection;
  Function getQueryCollection;
  String orderBy;
  Function addFilter;
  String reverseOrderBy;
  Function onSave;
  Function onUpdated;
  Function onRemove;
  int rowsPerPage;
  bool canAdd;
  bool canEdit;
  bool canRemove;

  List<ColumnModule> columns;
  Module({
    this.name,
    this.collection,
    this.getQueryCollection,
    this.addFilter,
    this.title,
    this.icon,
    this.columns,
    this.orderBy,
    this.reverseOrderBy,
    //this.sortBy,
    //this.reverseSortBy,
    this.rowsPerPage = 10,
    this.canAdd = true,
    this.canEdit = true,
    this.canRemove = true,
    this.onSave,
    this.onUpdated,
    this.onRemove,
  });
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

  ColumnModule(
      {this.label,
      this.field,
      this.type,
      this.editable = true,
      this.listable = true,
      this.clickToDetail = true,
      this.filter = false,
      this.mandatory = false,
      this.showOnEdit = true,
      this.showOnNew = true});

  getListContent(DocumentSnapshot _object) =>
      type.getListContent(_object, this);
  getEditContent(value, Function onValidate, Function onChange) =>
      type.getEditContent(value, this, onValidate, onChange);
  getFilterContent(value, Function onFilter) =>
      type.getFilterContent(value, this, onFilter);
}

abstract class MenuBase {
  String label;
  IconData iconData;
  String role;
  int idx;
  MenuBase({this.label, this.iconData, this.role});

  @override
  int get hashCode {
    return label.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return super == other;
  }
}

class Menu extends MenuBase {
  Widget child;

  Menu({this.child, String label, IconData iconData, String role})
      : super(label: label, iconData: iconData, role: role);
}

class MenuGroup extends MenuBase {
  List<Menu> children;
  MenuGroup({this.children, String label, IconData iconData, String role})
      : super(label: label, iconData: iconData, role: role);
}
