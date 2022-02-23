import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/screens/admin.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';

class AdminDataTable extends StatefulWidget {
  AdminDataTable({Key? key}) : super(key: key);

  @override
  State<AdminDataTable> createState() => _AdminDataTableState();
}

class _AdminDataTableState extends State<AdminDataTable> {
  void selectRow(BuildContext context, int index, DocumentSnapshot object) {
    print("select row $index");
    AdminScreenState? adminScreenState =
        context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null)
      throw new Exception("No encuentro AdminScreenState!!!");

    setState(() {
      adminScreenState.indexSelected.clear();
      adminScreenState.indexSelected.add(index);
      adminScreenState.rowsSelected.clear();
      adminScreenState.rowsSelected.add(object);
    });
  }

  void multiselectRow(
      BuildContext context, int index, DocumentSnapshot object, bool add) {
    print("multiSelectRow $index $add");
    AdminScreenState? adminScreenState =
        context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null)
      throw new Exception("No encuentro AdminScreenState!!!");
    if (add) {
      setState(() {
        adminScreenState.indexSelected.add(index);
        adminScreenState.rowsSelected.add(object);
      });
    } else {
      setState(() {
        adminScreenState.indexSelected.remove(index);
        adminScreenState.rowsSelected
            .removeWhere((obj) => obj.reference.path == object.reference.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AdminScreenState? adminScreenState =
        context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null)
      return Text("Error, no encuentro AdminScreen");

    return PaginatedDataTable2(
        onPageChanged: (page) {
          setState(() {});
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
                  if (adminScreenState.widget.module.canSort &&
                      adminScreenState
                          .widget.module.showingColumns[column].canSort) {
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
            (adminScreenState.widget.module.canRemove ||
                    adminScreenState.widget.module.getActions != null
                ? [DataColumn2(label: SizedBox.shrink(), size: ColumnSize.L)]
                : []),
        source: MyDataTableSource(
            docs: adminScreenState.docs!,
            context: context,
            parent: this,
            onTap: (index) {
              adminScreenState.showDetalle(index);
            },
            showFields: adminScreenState.columnasSeleccionadas));
  }
}

class MyDataTableSource extends DataTableSource {
  _AdminDataTableState parent;
  List<DocumentSnapshot> docs;
  BuildContext context;
  Function onTap;
  Map<String, bool> showFields;

  MyDataTableSource(
      {required this.docs,
      required this.context,
      required this.onTap,
      required this.showFields,
      required this.parent});

  @override
  DataRow getRow(int index) {
    AdminScreenState? adminScreenState =
        context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null)
      throw new Exception("No encuentro admin screen state!!!");

    Module module = adminScreenState.widget.module;

    DocumentSnapshot _object = docs[index];

    return DataRow2.byIndex(
        selected: adminScreenState.indexSelected.contains(index),
        index: index,
        onSelectChanged: (value) {
          parent.multiselectRow(context, index, _object, value ?? false);
        },
        cells: module.columns
                .where((element) =>
                    element.listable &&
                    this.showFields.containsKey(element.field) &&
                    this.showFields[element.field]!)
                .map<DataCell>((column) {
              // set context
              column.type.setContext(context);
              return DataCell(
                  column.getListContent(_object) ?? SizedBox.shrink(),
                  onTap: column.clickToDetail
                      ? () {
                          if (adminScreenState.widget.selectPreEdit &&
                              adminScreenState.indexSelected.contains(index) ==
                                  false) {
                            parent.selectRow(context, index, _object);
                          } else {
                            if (module.canEdit) {
                              this.onTap(index);
                            }
                          }
                        }
                      : null);
            }).toList() +
            (module.canRemove || module.getActions != null
                ? [
                    DataCell(
                      Row(
                          mainAxisSize: MainAxisSize.max,
                          children: (module.getActions == null
                                  ? <Widget>[]
                                  : module.getActions!(_object, context)) +
                              (module.canRemove
                                  ? [
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Theme.of(context)
                                                .highlightColor),
                                        onPressed: () {
                                          doBorrar(context, _object.reference,
                                              () {
                                            if (module.onRemove != null) {
                                              module.onRemove!(_object);
                                            }
                                          });
                                        },
                                      ),
                                    ]
                                  : [])),
                    )
                  ]
                : []));
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => docs.length;

  @override
  int get selectedRowCount => 0;
}
