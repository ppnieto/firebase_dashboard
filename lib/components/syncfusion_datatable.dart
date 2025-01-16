import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/components/syncfusion_datasource.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyncfusionDataTable extends StatelessWidget {
  final DashboardModule module;
  final DataGridController _controller = DataGridController();

  SyncfusionDataTable({Key? key, required this.module}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminController>(
        id: "listado",
        builder: (controller) {
          return SfDataGridTheme(
              data: SfDataGridThemeData(
                  headerColor: Theme.of(context).primaryColor.withOpacity(0.3),
                  filterIconColor: Theme.of(context).primaryColor,
                  sortIconColor: Theme.of(context).primaryColor),
              child: Builder(builder: (context) {
                AdminController? controller = DashboardUtils.findController<AdminController>(context: context);
                if (controller == null) {
                  return Text("Error, no encuentro AdminController");
                }
                if (controller.datagridSource == null)
                  return Center(
                      child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ));
                return SfDataGrid(
                    key: controller.newSfDatagridKey,
                    controller: _controller,
                    isScrollbarAlwaysShown: true,
                    allowColumnsResizing: true,
                    allowFiltering: true,
                    showColumnHeaderIconOnHover: true,
                    onColumnResizeUpdate: (ColumnResizeUpdateDetails details) => true,
                    showCheckboxColumn: controller.canSelect,
                    onColumnResizeEnd: (details) {
                      controller.columnWidths[details.column.columnName] = details.width;
                      controller.saveColumnWidths();
                    },
                    columnResizeMode: ColumnResizeMode.onResizeEnd,
                    columnWidthMode: ColumnWidthMode.none,
                    source: controller.datagridSource!,
                    tableSummaryRows: module.showSummary
                        ? [
                            GridTableSummaryRow(
                                showSummaryInRow: false,
                                position: GridTableSummaryRowPosition.bottom,
                                columns: controller.columns
                                    .map((col) => GridSummaryColumn(
                                          name: col.field,
                                          columnName: col.label,
                                          summaryType: GridSummaryType.sum,
                                        ))
                                    .toList())
                          ]
                        : [],
                    allowSorting: true,
                    frozenColumnsCount: module.firstFreezedColumns,
                    footerFrozenColumnsCount: controller.freezeLastColumn ? 1 : 0,
                    allowTriStateSorting: true,
                    selectionMode: controller.canSelect ? SelectionMode.multiple : SelectionMode.single,
                    navigationMode: GridNavigationMode.row,
                    loadMoreViewBuilder: (BuildContext context, LoadMoreRows loadMoreRows) {
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
                                      color: Theme.of(context).primaryColor,
                                      border: BorderDirectional(
                                          top: BorderSide(width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.26)))),
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor)));
                            } else {
                              return SizedBox.shrink();
                            }
                          });
                    },
                    onSelectionChanged: (addedRows, removedRows) {
                      for (var row in addedRows) {
                        DocumentSnapshot selected = (row as SyncfusionDataGridRow).doc;
                        controller.multiselectRow(context, selected, true);
                      }
                      for (var row in removedRows) {
                        DocumentSnapshot selected = (row as SyncfusionDataGridRow).doc;
                        controller.multiselectRow(context, selected, false);
                      }
                    },
                    onCellTap: (details) {
                      if (details.rowColumnIndex.rowIndex > 0) {
                        SyncfusionDataGridRow row = controller.datagridSource!
                            .effectiveRows[details.rowColumnIndex.rowIndex - 1] as SyncfusionDataGridRow;
                        DocumentSnapshot doc = row.doc;

                        if (module.selectPreEdit) {
                          print("selected = ${_controller.selectedIndex} / ${details.rowColumnIndex.rowIndex}");
                          if (_controller.selectedIndex + 1 == details.rowColumnIndex.rowIndex) {
                            // click on selected, nos vamos al detalle
                            controller.showDetalleObject(context, doc);
                            _controller.selectedIndex = -1;
                          }
                        } else {
                          controller.showDetalleObject(context, doc);
                          _controller.selectedIndex = -1;
                        }
                      }
                    },
                    showSortNumbers: true,
                    columns: controller.columns
                        .map<GridColumn>((col) => GridColumn(
                            allowSorting: col.canSort,
                            width: (col.field == '_acciones')
                                ? controller.module.actionColumnWidth ?? double.nan
                                : (controller.columnWidths[col.field] ?? double.nan),
                            columnName: col.field,
                            allowFiltering: col.filter,
                            label: Container(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                alignment: Alignment.centerRight,
                                child: Text(
                                  col.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).primaryColor),
                                ))))
                        .toList());
              }));
        });
  }
}
