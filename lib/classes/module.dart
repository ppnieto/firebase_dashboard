import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/classes/column.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class DashboardModule {
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
  final Future<bool> Function(bool, Map<String, dynamic>?, DocumentSnapshot? doc)? onSave;
  final Function? onUpdated;
  final Function(DocumentSnapshot)? onRemove;
  final Function(Map<String, dynamic>?)? onNew;
  final bool globalSearch;
  final Future<String?> Function(bool isNew, Map<String, dynamic> updateData)? validation;
  final int rowsPerPage;
  final bool canSelect;
  final bool canAdd;
  final bool canEdit;
  final bool canRemove;
  final bool canRemoveInList;
  int firstFreezedColumns;
  final bool deleteDisabled;
  final bool removeInEdit;
  final bool selectPreEdit;
  final bool canSort;
  final Color? Function(DocumentSnapshot)? backgroundColor;
  final bool exportExcel;
  final bool showColumnSelection;
  final bool compactColumnSelection;
  final double? actionColumnWidth;
  final bool showSummary;
  final bool fitColumns;
  final List<String> fieldsForShowInSearchResult;
  final List<Widget> Function(DocumentSnapshot object, BuildContext context)? getActions;
  final List<Widget> Function(BuildContext context)? getScaffoldActions;
  final bool debugInfo;

  List<ColumnModule> columns;
  //List<ColumnModule> showingColumns = [];

  DashboardModule(
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
      this.debugInfo = false,
      this.showSummary = false,
      this.canRemoveInList = true,
      this.firstFreezedColumns = 0,
      this.removeInEdit = false,
      this.selectPreEdit = false,
      this.canSort = true,
      this.canSelect = false,
      this.deleteDisabled = false,
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
      this.getScaffoldActions});
}
