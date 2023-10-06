import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyncfusionDataSource extends DataGridSource {
  final List<ColumnModule> columns;
  final Module module;
  List<DataGridRow> dataGridRows = [];

  SyncfusionDataSource({required this.columns, required this.module});

  @override
  Future<void> handleLoadMoreRows() async {
    Get.log('handleLoadMoreRows');
    AdminController controller = Get.find<AdminController>(tag: module.name);
    controller.nextPage();
  }

  Future<bool> buildDataGridRows() async {
    print("buildDataGridRows");
    AdminController controller = Get.find<AdminController>(tag: module.name);

    dataGridRows.clear();
    for (var doc in controller.docs) {
      List<DataGridCell> cells = [];
      for (var column in columns) {
        ColumnModule? columnModule = getColumnModuleByField(column.field);
        var value;
        if (columnModule != null) {
          if (columnModule.type.async()) {
            value = await columnModule.type.getAsyncValue(doc, column);
          } else {
            value = columnModule.type.getValue(doc, column);
          }
          if (value is Timestamp) {
            value = value.toDate();
          }
          //print("  column ${column.field} = $value");
          cells.add(DataGridCell(value: value, columnName: column.field));
        } else {
          throw new Exception("No encuentro columna para campo ${column.field}");
        }
      }
      dataGridRows.add(SyncfusionDataGridRow(cells: cells, doc: doc));
    }
    print("buildDataGridRows OK");
    return true;
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  ColumnModule? getColumnModuleByField(String field) => columns.firstWhere((element) => element.field == field);

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    SyncfusionDataGridRow myRow = row as SyncfusionDataGridRow;
    DocumentSnapshot doc = myRow.doc;
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      ColumnModule? column = getColumnModuleByField(dataGridCell.columnName);

      return Container(
        color: module.backgroundColor != null ? module.backgroundColor!(myRow.doc) : null,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        alignment: Alignment.centerRight,
        child: DefaultTextStyle(
            style: TextStyle(color: Theme.of(Get.context!).primaryColorDark),
            child: column?.type.getListContent(Get.context!, doc, column) ?? SizedBox.shrink()),
      );
    }).toList());
  }

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow, GridSummaryColumn? summaryColumn, RowColumnIndex rowColumnIndex, String summaryValue) {
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
