import 'dart:async';
//import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/screens/admin.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:intl/intl.dart';

class SyncfusionDataTable extends StatefulWidget {
  SyncfusionDataTable({Key? key}) : super(key: key);

  @override
  State<SyncfusionDataTable> createState() => SyncfusionDataTableState();
}

class SyncfusionDataTableState extends State<SyncfusionDataTable> {
  final DataGridController _controller = DataGridController();
  List<ColumnModule>? columns;
  AdminScreenState? adminScreenState;
  DocumentSnapshot? selected;
  bool noMoreElements = false;
  StreamSubscription<QuerySnapshot>? docSubscription;

  Future<List<DocumentSnapshot>> loadAll() async {
    Query query = adminScreenState!.getQuery();
    QuerySnapshot qs = await query.get();
    return qs.docs;
  }

  Future<void> exportDataGridToExcel() async {
    final xlsio.Workbook workbook = _key.currentState!.exportToExcelWorkbook();

    List<int> bytes = workbook.saveAsStream();
    DateTime now = DateTime.now();
    String suffix = DateFormat('yyyyMMdd').format(now);
    String fileName = adminScreenState!.widget.module.name + '_$suffix.xls';
    DashboardUtils.download(fileName, bytes);
  }

  updateColumns() {
    adminScreenState = context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState != null) {
      //columns = List.from(adminScreenState!.widget.module.columns);
      columns = List.from(adminScreenState!.widget.module.showingColumns);
    } else {
      columns = [];
    }
    if (adminScreenState!.widget.module.canRemove ||
        adminScreenState!.widget.module.getActions != null) {
      columns!.add(ColumnModule(
          field: "_acciones",
          label: "",
          width: adminScreenState!.widget.module.actionColumnWidth,
          type: FieldTypeWidget(
            builder: (context, object, inList) {
              return Row(
                children: [
                  ...adminScreenState!.widget.module.getActions != null
                      ? adminScreenState!.widget.module.getActions!(
                          object!, context)
                      : [],
                  if (adminScreenState!.widget.module.canRemove)
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: Theme.of(context).highlightColor),
                      onPressed: () {
                        adminScreenState?.doBorrar(
                            context, object!.reference, () {});
                      },
                    ),
                  SizedBox(width: 15)
                ],
              );
            },
          )));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    docSubscription?.cancel();
  }

  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  @override
  Widget build(BuildContext context) {
    DashboardMainScreenState? dashboardState =
        context.findAncestorStateOfType<DashboardMainScreenState>();
    if (dashboardState == null)
      throw new Exception("No encuentro admin screen state!!!");

    updateColumns();
    return SfDataGridTheme(
      data: SfDataGridThemeData(
          selectionColor: dashboardState.widget.theme?.appBar2BackgroundColor
                  ?.withOpacity(0.6) ??
              Theme.of(context).secondaryHeaderColor.withOpacity(0.6),
          rowHoverColor: dashboardState.widget.theme?.appBar2BackgroundColor
                  ?.withOpacity(0.2) ??
              Theme.of(context).secondaryHeaderColor.withOpacity(0.2),
          headerColor: Theme.of(context).primaryColor.withOpacity(0.3),
          sortIconColor: Theme.of(context).primaryColor),
      child: SfDataGrid(
          key: _key,
          controller: _controller,
          showCheckboxColumn: adminScreenState?.canSelect ?? false,
          //footerFrozenColumnsCount: 1,
          columnWidthMode: ColumnWidthMode.fill,
          source: _DataSource(
              columns: columns!, context: context, parentState: this),
          allowSorting: true,
          allowTriStateSorting: true,
          selectionMode: adminScreenState!.canSelect
              ? SelectionMode.multiple
              : SelectionMode.single,
          navigationMode: GridNavigationMode.row,
          loadMoreViewBuilder:
              (BuildContext context, LoadMoreRows loadMoreRows) {
            if (noMoreElements) {
              return SizedBox.shrink();
            }

            Future<String> loadRows() async {
              await loadMoreRows();
              return Future<String>.value('Completed');
            }

            return FutureBuilder<String>(
                initialData: 'loading',
                future: loadRows(),
                builder: (context, snapShot) {
                  if (snapShot.data == 'loading') {
                    return Container(
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: BorderDirectional(
                                top: BorderSide(
                                    width: 1.0,
                                    color: Color.fromRGBO(0, 0, 0, 0.26)))),
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).primaryColor)));
                  } else {
                    return SizedBox.shrink();
                  }
                });
          },
          onSelectionChanged: (addedRows, removedRows) {
            if (addedRows.isNotEmpty) {
              selected = addedRows.single.getCells().first.value.doc;
              adminScreenState!.rowsSelected.add(selected!);
            }
            if (removedRows.isNotEmpty) {
              DocumentSnapshot removed =
                  removedRows.single.getCells().first.value.doc;
              adminScreenState!.rowsSelected.remove(removed);
            }

            if (adminScreenState!.widget.selectPreEdit == false) {
              if (selected != null) {
                adminScreenState?.showDetalleObject(selected);
                _controller.selectedIndex = -1;
              }
            }
          },
          onCellTap: (details) {
            if (adminScreenState!.widget.selectPreEdit &&
                _controller.selectedIndex ==
                    details.rowColumnIndex.rowIndex - 1) {
              if (selected != null) {
                adminScreenState?.showDetalleObject(selected);
                _controller.selectedIndex = -1;
              }
            }
          },
          showSortNumbers: true,
          columns: columns!
              .map<GridColumn>((col) => GridColumn(
                  allowSorting: true,
                  width: col.width ?? double.nan,
                  columnName: col.field,
                  label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      alignment: Alignment.centerRight,
                      child: Text(
                        col.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Theme.of(context).primaryColor),
                      ))))
              .toList()),
    );
  }
}

class _DataSource extends DataGridSource {
  final BuildContext context;
  final List<ColumnModule> columns;
  final SyncfusionDataTableState parentState;

  _DataSource(
      {required this.columns,
      required this.context,
      required this.parentState}) {
    handleLoadMoreRows();
    buildDataGridRows();
  }

  List<DataGridRow> dataGridRows = [];
  List<DocumentSnapshot> docs = [];

  @override
  Future<void> handleLoadMoreRows() async {
    AdminScreenState? adminScreenState =
        context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null)
      throw new Exception("No encuentro admin screen state!!!");

    int limit = adminScreenState.getPageSize() + docs.length;

    StreamSubscription<QuerySnapshot>? tempSubscription =
        adminScreenState.getQuery().limit(limit).snapshots().listen((value) {
      //print("traemos " + value.docs.length.toString() + " / " + limit.toString());
      if (value.docs.length < limit && limit > adminScreenState.getPageSize()) {
        parentState.noMoreElements = true;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Final del listado alcanzado"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ));
      }
      docs.clear();
      docs.addAll(value.docs);
      adminScreenState.docs = List.from(docs);

      buildDataGridRows();
      notifyListeners();
    });

    if (parentState.docSubscription != null) {
      await parentState.docSubscription!.cancel();
      parentState.docSubscription = tempSubscription;
    }
  }

  void buildDataGridRows() {
    dataGridRows = docs.map((doc) {
      return DataGridRow(
          cells: columns.map((column) {
        return DataGridCell(
            value: _DocumentSnapshotWrapper(doc: doc, field: column.field),
            columnName: column.field);
      }).toList());
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  ColumnModule? getColumnModuleByField(String field) =>
      columns.firstWhere((element) => element.field == field);

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    DashboardMainScreenState? dashboardState =
        context.findAncestorStateOfType<DashboardMainScreenState>();
    if (dashboardState == null)
      throw new Exception("No encuentro admin screen state!!!");

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      ColumnModule? column = getColumnModuleByField(dataGridCell.columnName);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        alignment: Alignment.centerRight,
        child: DefaultTextStyle(
            style: TextStyle(color: Theme.of(context).primaryColor),
            child: column?.type
                    .getListContent(context, dataGridCell.value.doc, column) ??
                SizedBox.shrink()),
      );
    }).toList());
  }
}

class _DocumentSnapshotWrapper extends Comparable {
  final DocumentSnapshot doc;
  final String field;

  _DocumentSnapshotWrapper({required this.doc, required this.field});

  @override
  int compareTo(other) {
    if (other is _DocumentSnapshotWrapper) {
      if (!doc.hasFieldAdm(field)) return 1;
      if (!other.doc.hasFieldAdm(field)) return -1;
      var val1 = doc.get(field);
      var val2 = other.doc.get(field);
      if (val1 is DocumentReference) return val1.path.compareTo(val2.path);
      return val1.compareTo(val2);
    }
    return 0;
  }
}
