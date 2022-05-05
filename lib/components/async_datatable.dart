import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/screens/admin.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class AsyncAdminDataTable extends StatefulWidget {
  AsyncAdminDataTable({Key? key}) : super(key: key);

  @override
  State<AsyncAdminDataTable> createState() => _AsyncAdminDataTableState();
}

class _AsyncAdminDataTableState extends State<AsyncAdminDataTable> {
  void selectRow(BuildContext context, int index, DocumentSnapshot object) {
    print("select row $index");
    AdminScreenState? adminScreenState = context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null) throw new Exception("No encuentro AdminScreenState!!!");

    setState(() {
      //adminScreenState.indexSelected.clear();
      //adminScreenState.indexSelected.add(index);
      adminScreenState.rowsSelected.clear();
      adminScreenState.rowsSelected.add(object);
    });
  }

  void multiselectRow(BuildContext context, int index, DocumentSnapshot object, bool add) {
    print("multiSelectRow $index $add");
    AdminScreenState? adminScreenState = context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null) throw new Exception("No encuentro AdminScreenState!!!");
    if (add) {
      setState(() {
        //adminScreenState.indexSelected.add(index);
        adminScreenState.rowsSelected.add(object);
      });
    } else {
      setState(() {
        //adminScreenState.indexSelected.remove(index);
        adminScreenState.rowsSelected.removeWhere((obj) => obj.reference.path == object.reference.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AdminScreenState? adminScreenState = context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null) return Text("Error, no encuentro AdminScreen");

    print("columnas en lista: " + adminScreenState.widget.module.showingColumns.length.toString());

    return AsyncPaginatedDataTable2(
        onPageChanged: (page) {
          //setState(() {});
        },
        sortAscending: adminScreenState.sortAscending,
        sortColumnIndex: adminScreenState.sortColumnIndex,
        showCheckboxColumn: adminScreenState.canSelect,
        columnSpacing: 0.0,
        dataRowHeight: 38,
        minWidth: adminScreenState.widget.minWidth,
        lmRatio: 1.8,
        autoRowsToHeight: true,
        columns: adminScreenState.widget.module.showingColumns.map((column) {
              return DataColumn2(
                onSort: (int column, bool ascending) {
                  if (adminScreenState.widget.module.canSort && adminScreenState.widget.module.showingColumns[column].canSort) {
                    adminScreenState.setState(() {
                      adminScreenState.sortAscending = ascending;
                      adminScreenState.sortColumnIndex = column;
                    });
                  }
                },
                size: column.size,
                label: Text(column.label),
              );
            }).toList() +
            (adminScreenState.widget.module.canRemove || adminScreenState.widget.module.getActions != null
                ? [DataColumn2(label: SizedBox.shrink(), size: ColumnSize.L)]
                : []),
        source: MyDataTableSource(
            context: context,
            parent: this,
            onTap: (index) {
              print("on tap datatable " + index.toString());
              adminScreenState.showDetalle(index);
            },
            showFields: adminScreenState.columnasSeleccionadas));
  }
}

class MyDataTableSource extends AsyncDataTableSource {
  _AsyncAdminDataTableState parent;
  BuildContext context;
  Function onTap;
  Map<String, bool> showFields;

  MyDataTableSource({required this.context, required this.onTap, required this.showFields, required this.parent});

  @override
  Future<AsyncRowsResponse> getRows(int start, int end) async {
    print("get rows $start / $end");
    AdminScreenState? adminScreenState = context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null) throw new Exception("No encuentro admin screen state!!!");

    Query query = adminScreenState.getQuery().limit(adminScreenState.docs!.length + end);
    if (adminScreenState.docs?.isNotEmpty ?? false) {
      print("start after " + adminScreenState.docs!.last.reference.path);
    }
    QuerySnapshot qs = await query.get();
    List<DataRow> rows = [];

    adminScreenState.docs?.clear();
    adminScreenState.docs?.addAll(qs.docs);
    try {
      for (int i = start; i < start + end; i++) {
        DocumentSnapshot doc = adminScreenState.docs![i];
        //adminScreenState.docs!.where((element) => element.reference.path == doc.reference.path).isEmpty) {
        print(doc.reference.path);
        rows.add(DataRow2(
            cells: adminScreenState.widget.module.showingColumns.map((column) {
          //cells: module.columns.where((element) => element.listable && this.showFields.containsKey(element.field) && this.showFields[element.field]!).map<DataCell>((column) {
          // set context
          return DataCell(column.type.getListContent(context, doc, column) ?? SizedBox.shrink(),
              onTap: column.clickToDetail
                  ? () {
                      /*
                    if (adminScreenState.widget.selectPreEdit && adminScreenState.indexSelected.contains(index) == false) {
                      parent.selectRow(context, index, _object);
                    } else {
                      if (module.canEdit) {
                        this.onTap(index);
                      }
                    }
                    */
                    }
                  : null);
        }).toList()));
      }
    } catch (e) {
      print("error");
    }

    for (var row in rows) {
      print("columnas en fila: " + row.cells.length.toString());
    }

    return AsyncRowsResponse(rows.length, rows);
    //return AsyncRowsResponse(rows.length < (end - start) ? rows.length : 150, rows);
  }

  @override
  bool get isRowCountApproximate => true;
/*
  @override
  int get rowCount => docs.length;

  @override
  int get selectedRowCount => 0;*/
}
