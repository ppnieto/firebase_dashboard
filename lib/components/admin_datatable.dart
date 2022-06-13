import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/screens/admin.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';

class AdminDataTable extends StatefulWidget {
  AdminDataTable({Key? key}) : super(key: key);

  @override
  State<AdminDataTable> createState() => AdminDataTableState();
}

class AdminDataTableState extends State<AdminDataTable> {
  void selectRow(BuildContext context, DocumentSnapshot object) {
    AdminScreenState? adminScreenState = context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null) throw new Exception("No encuentro AdminScreenState!!!");

    setState(() {
      adminScreenState.rowsSelected.clear();
      adminScreenState.rowsSelected.add(object);
    });
  }

  void unselectAll() {
    AdminScreenState? adminScreenState = context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null) throw new Exception("No encuentro AdminScreenState!!!");

    setState(() {
      adminScreenState.rowsSelected.clear();
    });
  }

  void multiselectRow(BuildContext context, DocumentSnapshot object, bool add) {
    print("multiSelectRow " + object.reference.path);
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
              ColumnSize cs = column.size;
              if (column.width != null) {
                if (column.width! <= 120)
                  cs = ColumnSize.S;
                else if (column.width! <= 150)
                  cs = ColumnSize.M;
                else
                  cs = ColumnSize.L;
              }
              return DataColumn2(
                onSort: (int column, bool ascending) {
                  if (adminScreenState.widget.module.canSort && adminScreenState.widget.module.showingColumns[column].canSort) {
                    adminScreenState.setState(() {
                      adminScreenState.sortAscending = ascending;
                      adminScreenState.sortColumnIndex = column;
                    });
                  }
                },
                size: cs, //column.size,
                label: Text(column.label),
              );
            }).toList() +
            (adminScreenState.widget.module.canRemove || adminScreenState.widget.module.getActions != null
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
  AdminDataTableState parent;
  List<DocumentSnapshot> docs;
  BuildContext context;
  Function onTap;
  Map<String, bool> showFields;

  MyDataTableSource({required this.docs, required this.context, required this.onTap, required this.showFields, required this.parent});

  @override
  DataRow getRow(int index) {
    AdminScreenState? adminScreenState = context.findAncestorStateOfType<AdminScreenState>();
    if (adminScreenState == null) throw new Exception("No encuentro admin screen state!!!");

    Module module = adminScreenState.widget.module;

    DocumentSnapshot _object = docs[index];

    bool isSelected = adminScreenState.rowsSelected.where((element) => element.reference.path == _object.reference.path).isNotEmpty;

    return DataRow2.byIndex(
        selected: isSelected, //  adminScreenState.indexSelected.contains(index),
        index: index,
        onSelectChanged: (value) {
          parent.multiselectRow(context, _object, value ?? false);
        },
        cells: module.columns
                .where((element) => element.listable && this.showFields.containsKey(element.field) && this.showFields[element.field]!)
                .map<DataCell>((column) {
              // set context
              return DataCell(column.type.getListContent(context, _object, column) ?? SizedBox.shrink(),
                  onTap: column.clickToDetail
                      ? () {
                          if (adminScreenState.widget.selectPreEdit && isSelected == false) {
                            parent.selectRow(context, _object);
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
                          children: (module.getActions == null ? <Widget>[] : module.getActions!(_object, context)) +
                              (module.canRemove
                                  ? [
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Theme.of(context).highlightColor),
                                        onPressed: () {
                                          adminScreenState.doBorrar(context, _object.reference, () {
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
