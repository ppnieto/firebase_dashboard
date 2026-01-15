import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/classes/dashboard_theme.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyncfusionDataSource extends DataGridSource {
  final List<ColumnModule> columns;
  final DashboardModule module;
  final AdminController controller;
  List<DataGridRow> dataGridRows = [];

  SyncfusionDataSource({required this.columns, required this.module, required this.controller});

  @override
  Future<void> handleLoadMoreRows() async {
    Get.log('handleLoadMoreRows');
    controller.nextPage();
  }

  Future<bool> buildDataGridRows() async {
    dataGridRows.clear();
    for (var doc in controller.docs) {
      List<DataGridCell> cells = [];
      for (var column in columns) {
        ColumnModule? columnModule = getColumnModuleByField(column.field);
        var value;
        if (columnModule != null) {
          if (columnModule.type.async()) {
            Get.log('await for async column ${columnModule.field} in row ${doc.reference.id}');
            value = await columnModule.type.getAsyncValue(doc, column);
          } else {
            value = columnModule.type.getValue(doc, column);
          }
          if (value is Timestamp) {
            value = DashboardDate.from(value.toDate());
          }
          cells.add(DataGridCell(value: value, columnName: column.field));
        } else {
          throw new Exception("No encuentro columna para campo ${column.field}");
        }
      }
      dataGridRows.add(SyncfusionDataGridRow(cells: cells, doc: doc));
    }
    return true;
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  ColumnModule? getColumnModuleByField(String field) => columns.firstWhere((element) => element.field == field);

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    SyncfusionDataGridRow myRow = row as SyncfusionDataGridRow;
    DocumentSnapshot doc = myRow.doc;
    bool selected = controller.datagridController.selectedRows.contains(row);          
    return DataGridRowAdapter(
      color: selected ? DashboardThemeController.to.dataGridSelectedCellBackgroundColor : DashboardThemeController.to.dataGridCellBackgroundColor,      
      cells: row.getCells().map<Widget>((dataGridCell) {
        ColumnModule? column = getColumnModuleByField(dataGridCell.columnName);
        return Container(
          color: selected ?  DashboardThemeController.to.dataGridSelectedCellBackgroundColor : null,          
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          alignment: Alignment.centerRight,
          child: Builder(builder: (context) {
            Color contentColor = selected ? DashboardThemeController.to.dataGridSelectedCellColor : DashboardThemeController.to.dataGridCellColor;
            return Theme(
              data: ThemeData(
                iconButtonTheme: IconButtonThemeData(
                  style: ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(contentColor)
                  )
                ),
                iconTheme:IconThemeData(color: selected ? DashboardThemeController.to.dataGridSelectedCellColor : DashboardThemeController.to.dataGridCellColor)
              ),
              child: DefaultTextStyle(
                style: TextStyle(color: contentColor),
                child: column?.type.getListContent(context, doc, column) ?? SizedBox.shrink(),
              ),
            );
        }),
      );
    }).toList());
  }

  @override
  Widget? buildTableSummaryCellWidget(GridTableSummaryRow summaryRow, GridSummaryColumn? summaryColumn, RowColumnIndex rowColumnIndex, String summaryValue) {
    return summaryValue.isEmpty
        ? const SizedBox.shrink()
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            alignment: Alignment.centerRight,
            child: Text("SUM: $summaryValue",
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(Get.context!).primaryColorDark,
                )),
          );
  }
}

class SyncfusionDataGridRow extends DataGridRow {
  final DocumentSnapshot doc;
  SyncfusionDataGridRow({required List<DataGridCell> cells, required this.doc}) : super(cells: cells);
}

class DashboardDate extends DateTime {
  DashboardDate.now() : super.now();
  DashboardDate.from(DateTime dt) : super(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);

  @override
  toString() {
    final f = new DateFormat('dd/MM/yyyy');
    return f.format(this);
  }
}
