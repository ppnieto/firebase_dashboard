import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:dashboard/admin/screens/admin.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';

class AdminDataTable extends StatefulWidget {
  final AdminScreenState adminScreen;
  AdminDataTable({Key? key, required this.adminScreen}) : super(key: key);

  @override
  State<AdminDataTable> createState() => _AdminDataTableState();
}

class _AdminDataTableState extends State<AdminDataTable> {
  @override
  Widget build(BuildContext context) {
    AdminScreen parent = widget.adminScreen.widget;

    return PaginatedDataTable2(
        onPageChanged: (page) {
          setState(() {});
        },
        sortAscending: widget.adminScreen.sortAscending,
        sortColumnIndex: widget.adminScreen.sortColumnIndex,
        showCheckboxColumn: widget.adminScreen.canSelect,
        columnSpacing: 0.0,
        dataRowHeight: 38,
        minWidth: widget.adminScreen.widget.minWidth,
        lmRatio: 1.8,
        autoRowsToHeight: true,
        columns: parent.module.columns
                .where((element) =>
                    element.listable &&
                    widget.adminScreen.columnasSeleccionadas.containsKey(element.field) &&
                    widget.adminScreen.columnasSeleccionadas[element.field]!)
                .map((column) {
              return DataColumn2(
                onSort: (int column, bool ascending) {
                  if (parent.module.canSort) {
                    widget.adminScreen.setState(() {
                      widget.adminScreen.sortAscending = ascending;
                      widget.adminScreen.sortColumnIndex = column;
                    });
                  }
                },
                size: column.size,
                label: Text(column.label),
              );
            }).toList() +
            (parent.module.canRemove || parent.module.getActions != null ? [DataColumn2(label: SizedBox.shrink(), size: ColumnSize.L)] : []),
        source: MyDataTableSource(
            docs: widget.adminScreen.docs!,
            context: context,
            screen: widget.adminScreen,
            onTap: (index) {
              widget.adminScreen.setState(() {
                widget.adminScreen.detalle = widget.adminScreen.docs![index];
                widget.adminScreen.updateData = widget.adminScreen.detalle?.data() as Map<String, dynamic>?;
                widget.adminScreen.tipo = TipoPantalla.detalle;
              });
            },
            showFields: widget.adminScreen.columnasSeleccionadas));
  }
}

class MyDataTableSource extends DataTableSource {
  List<DocumentSnapshot> docs;
  BuildContext context;
  AdminScreenState screen;
  Function onTap;
  Map<String, bool> showFields;
  MyDataTableSource({
    required this.docs,
    required this.screen,
    required this.context,
    required this.onTap,
    required this.showFields,
  });
  @override
  DataRow getRow(int index) {
    Module module = screen.widget.module;

    DocumentSnapshot _object = docs[index];

    return DataRow2.byIndex(
        selected: screen.widget.module.indexSelected.contains(index),
        index: index,
        onSelectChanged: (value) {
          print("onSelectChanged ${screen.widget.module.indexSelected}");
          screen.setState(() {
            if (value ?? false) {
              screen.widget.module.indexSelected.add(index);
              screen.widget.module.rowsSelected.add(_object);
            } else {
              screen.widget.module.indexSelected.remove(index);
              screen.widget.module.rowsSelected.removeWhere((obj) => obj.reference.path == _object.reference.path);
            }
          });
        },
        cells: module.columns
                .where((element) => element.listable && this.showFields.containsKey(element.field) && this.showFields[element.field]!)
                .map<DataCell>((column) {
              // set context
              column.type.setContext(context);
              return DataCell(column.getListContent(_object),
                  onTap: column.clickToDetail
                      ? () {
                          if (screen.widget.selectPreEdit && screen.widget.module.indexSelected.contains(index) == false) {
                            screen.setState(() {
                              screen.widget.module.indexSelected.clear();
                              screen.widget.module.indexSelected.add(index);
                              screen.widget.module.rowsSelected.clear();
                              screen.widget.module.rowsSelected.add(_object);
                            });
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
                          children: (module.getActions == null ? <Widget>[] : module.getActions!(_object, context)) +
                              (module.canRemove
                                  ? [
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Theme.of(context).highlightColor),
                                        onPressed: () {
                                          doBorrar(context, _object.reference, () {
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
