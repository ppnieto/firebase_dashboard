import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyncfusionDataTable extends StatelessWidget {
  final List<ColumnModule> columns;
  final List<DocumentSnapshot> docs;
  final Function onTap;
  final DataGridController _controller = DataGridController();
  SyncfusionDataTable(
      {Key? key,
      required this.columns,
      required this.docs,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
        controller: _controller,
        source: _DataSource(docs: docs, columns: columns),
        allowColumnsResizing: true,
        selectionMode: SelectionMode.single,
        onCellTap: (details) {
          if (_controller.selectedIndex ==
              details.rowColumnIndex.rowIndex - 1) {
            onTap(details.rowColumnIndex.rowIndex - 1);
          }
        },
        columns: this
            .columns
            .map((col) => GridColumn(
                allowSorting: true,
                columnWidthMode: ColumnWidthMode.fill,
                columnName: col.field,
                label: Container(
                    padding: EdgeInsets.all(16.0),
                    alignment: Alignment.centerLeft,
                    child: Text(col.label))))
            .toList());
  }
}

class _DataSource extends DataGridSource {
  final List<DocumentSnapshot> docs;
  final List<ColumnModule> columns;

  _DataSource({required this.docs, required this.columns});

  @override
  List<DataGridRow> get rows => docs.map((doc) {
        return DataGridRow(
            cells: columns.map((column) {
          return DataGridCell(value: doc, columnName: column.field);
        }).toList());
      }).toList();

  ColumnModule getColumnModuleByField(String field) =>
      columns.firstWhere((element) => element.field == field);

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: getColumnModuleByField(dataGridCell.columnName)
              .getListContent(dataGridCell.value));
    }).toList());
  }
}
