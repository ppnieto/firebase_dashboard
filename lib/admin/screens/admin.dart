import 'dart:developer';

import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/admin/screens/detalle.dart';
import 'package:firebase_dashboard/components/admin_datatable.dart';
import 'package:firebase_dashboard/components/async_datatable.dart';
import 'package:firebase_dashboard/components/syncfusion_datatable.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

enum DataTableImplementation { AdminDataTable, AsyncDataTable, SyncfusionDataTable }

class AdminScreen extends StatefulWidget {
  final Module module;
  final bool showScaffoldBack;
  final bool selectPreEdit;
  final CollectionReference? collection;
  final double minWidth;
  final double labelWidth;
  final DataTableImplementation dataTableImplementation;

  Map<String, dynamic> filtroInicial = {};

  AdminScreen(
      {Key? key,
      required this.module,
      this.showScaffoldBack = false,
      this.minWidth = 200,
      this.selectPreEdit = false,
      this.collection,
      this.labelWidth = 120,
      this.dataTableImplementation = DataTableImplementation.SyncfusionDataTable})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AdminScreenState();
}

class AdminScreenState extends State<AdminScreen> {
  bool canSelect = false;
  String? _orderBy;
  List<DocumentSnapshot>? docs;
  String? globalSearch;
  Map<String, dynamic> filtro = {};
  final scrollController = ScrollController();
  bool sortAscending = true;
  int? sortColumnIndex;
  Map<String, bool> columnasSeleccionadas = {};
  List<DocumentSnapshot> rowsSelected = [];

  @override
  initState() {
    super.initState();
    if (widget.filtroInicial.isNotEmpty) this.filtro = widget.filtroInicial;
  }

  Future<bool> initAdmin() async {
    print("init admin");
    _orderBy = widget.module.orderBy;

    canSelect = widget.module.canSelect;

    rowsSelected = [];

    docs = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String key = 'admin_columns_' + widget.module.name;
      if (prefs.containsKey(key)) {
        List<String> sel = prefs.getStringList(key)!;
        for (var col in widget.module.columns) {
          columnasSeleccionadas[col.field] = false;
        }
        for (var s in sel) {
          columnasSeleccionadas[s] = true;
        }
      } else {
        for (var col in widget.module.columns) {
          columnasSeleccionadas[col.field] = true;
        }
      }
      onUpdateColumnasSeleccionadas();
    } catch (e) {
      print("error: ");
      print(e);
    }
    preloadReferences();

    return true;
  }

  void onUpdateColumnasSeleccionadas() {
    widget.module.showingColumns = widget.module.columns
        .where((col) => col.listable && columnasSeleccionadas.containsKey(col.field) && columnasSeleccionadas[col.field]!)
        .toList();
  }

  Future<void> preloadReferences() async {
    for (var column in widget.module.columns) {
      await column.type.preloadData();
    }
  }

  CollectionReference _getCollection() {
    if (widget.module.getQueryCollection != null) {
      return widget.module.getQueryCollection!();
    } else {
      String collection = widget.collection?.path ?? widget.module.collection ?? widget.collection?.path ?? "";
      return FirebaseFirestore.instance.collection(collection);
    }
  }

  Query addFilters(Map<String, dynamic> filtro, Query query) {
    Query result = query;
    for (MapEntry filterEntry in filtro.entries) {
      if (filterEntry.value != null && filterEntry.value.toString().isNotEmpty) {
        print("   add filter " + filterEntry.key + " = " + filterEntry.value.toString());
        result = result.where(filterEntry.key, isEqualTo: filterEntry.value);
      }
    }
    return result;
  }

  void doGlobalSearch() {
    List<DocumentSnapshot> result = [];
    for (DocumentSnapshot doc in docs ?? []) {
      for (var column in widget.module.columns) {
        if (doc.hasFieldAdm(column.field)) {
          String value = column.type.getSyncStringContent(doc, column);

          bool encontrado = value.toLowerCase().contains(this.globalSearch!.toLowerCase());
          if (encontrado) {
            result.add(doc);
            break;
          }
        }
      }
    }
    this.docs = result;
  }

  showDetalle(index) {
    showDetalleObject(docs![index]);
  }

  showDetalleObject(object) {
    if (widget.module.canEdit) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetalleScreen(
                  object: object,
                  module: widget.module,
                  labelWidth: widget.labelWidth,
                )),
      );
    }
  }

  Query getQuery() {
    Query query = _getCollection();
    query = addFilters(filtro, query);
    if (widget.module.addFilter != null) {
      query = widget.module.addFilter!(query);
    }

    if (_orderBy != null) {
      query = query.orderBy(_orderBy!);
    }

    if (widget.module.reverseOrderBy != null) {
      query = query.orderBy(widget.module.reverseOrderBy!, descending: true);
    }
    return query;
  }

  GlobalKey<SyncfusionDataTableState> keyDataTable = GlobalKey<SyncfusionDataTableState>();

  Future<void> loading(BuildContext context, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withAlpha(140),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                SizedBox(width: 10),
                new Text(message, style: TextStyle(color: Colors.white, fontSize: 13.0, fontFamily: "AvenirBlack"))
              ],
            ),
          ),
        );
      },
    ); // bajamos la resolucion
  }

  GlobalKey<AdminDataTableState>? adminDataTableKey;

  Widget getDataTable(BuildContext context) {
    if (widget.dataTableImplementation == DataTableImplementation.SyncfusionDataTable) {
      return SyncfusionDataTable(key: keyDataTable);
    } else {
      // if (widget.dataTableImplementation == DataTableImplementation.AdminDataTable) {

      return StreamBuilder(
          stream: getQuery().snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return SizedBox.shrink();
            }
            print("reload docs...");
            docs = List.from(snapshot.data!.docs);
            if (widget.module.doFilter != null) {
              docs = widget.module.doFilter!(docs);
            }
            if (this.globalSearch != null) {
              doGlobalSearch();
            }

            if (widget.module.canSort && sortColumnIndex != null) {
              var column = widget.module.showingColumns[sortColumnIndex!];
              //print("ordenamos por columna " + column.label);
              this.docs?.sort((a, b) {
                var varA = column.type.getCompareValue(a, column);
                var varB = column.type.getCompareValue(b, column);
                return this.sortAscending ? varA?.compareTo(varB) : varB?.compareTo(varA);
              });
            }
            adminDataTableKey = GlobalKey<AdminDataTableState>();
            return AdminDataTable(key: adminDataTableKey);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> getLeading() {
      return [
        SizedBox(width: 10),
        if (Navigator.of(context).canPop())
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        IconButton(
            icon: Icon(FontAwesomeIcons.listUl),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (ctx) {
                  return MultiSelectDialog<String>(
                    items: widget.module.columns.map((ColumnModule columnModule) {
                      return MultiSelectItem(columnModule.field, columnModule.label);
                    }).toList(),
                    initialValue: columnasSeleccionadas.entries.map((e) {
                      if (e.value) return e.key;
                      return "";
                    }).toList(),
                    searchable: false,
                    confirmText: Text('Aceptar'),
                    cancelText: Text('Cancelar'),
                    title: Text("Seleccione las columnas para mostrar"),
                    onConfirm: (values) {
                      setState(() {
                        columnasSeleccionadas.clear();
                        for (var value in values) {
                          columnasSeleccionadas[value] = true;
                        }

                        onUpdateColumnasSeleccionadas();

                        SharedPreferences.getInstance().then((SharedPreferences prefs) {
                          String key = 'admin_columns_' + widget.module.name;
                          prefs.setStringList(key, values);
                        });
                      });
                    },
                  );
                },
              );
            }),
      ];
    }

    Widget getGlobalSearch() {
      Color highlightColor =
          context.findAncestorStateOfType<DashboardMainScreenState>()?.widget.theme?.appBar1TextColor ?? Theme.of(context).primaryColor;

      return Container(
        width: 280,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            suffixIcon: Icon(Icons.search, color: highlightColor),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
              borderRadius: BorderRadius.circular(6.0),
            ),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: highlightColor, width: 2.0)),
            hintText: "Buscar...",
            hintStyle: TextStyle(color: highlightColor),
            contentPadding: EdgeInsets.all(10),
          ),
          style: TextStyle(color: highlightColor),
          onChanged: (value) {
            setState(() {
              this.globalSearch = value;
            });
          },
        ),
      );
    }

    void exportExcel() async {
      await loading(context, "Por favor espere...");
      try {
        List<DocumentSnapshot> allDocs = [];
        if (widget.dataTableImplementation == DataTableImplementation.SyncfusionDataTable) {
          allDocs = await keyDataTable.currentState!.loadAll();
        } else {
          allDocs = docs ?? [];
        }

        final xlsio.Workbook workbook = new xlsio.Workbook();
        final xlsio.Worksheet sheet = workbook.worksheets[0];

        List<xlsio.ExcelDataRow> rows = [];

        List<ColumnModule> columnasExportables = widget.module.columns.where((e) => e.listable && e.excellable).toList();

        for (var doc in allDocs) {
          List<xlsio.ExcelDataCell> cells = [];
          for (var column in columnasExportables) {
            var value = column.type.getSyncStringContent(doc, column);
            cells.add(xlsio.ExcelDataCell(value: value, columnHeader: column.label));
          }

          rows.add(xlsio.ExcelDataRow(cells: cells));
        }

        sheet.importData(rows, 1, 1);
        List<int> bytes = workbook.saveAsStream();
        String suffix = DateFormat('yyyyMMdd').format(DateTime.now());
        String fileName = widget.module.name + '_$suffix.xls';
        DashboardUtils.download(fileName, bytes);
      } finally {
        Navigator.of(context).pop();
      }
    }

    getActions() {
      List<Widget> result = [];

      if (widget.module.getScaffoldActions != null) {
        result.addAll(widget.module.getScaffoldActions!(context, this));
      }

      if (widget.module.globalSearch && widget.dataTableImplementation == DataTableImplementation.AdminDataTable) {
        result.add(getGlobalSearch());
      }

      if (widget.module.exportExcel) {
        result.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              label: Text("Exportar a excel"),
              icon: Icon(FontAwesomeIcons.fileExcel),
              onPressed: () {
                exportExcel();
              },
            )));
      }
      if (widget.module.canAdd) {
        result.add(IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetalleScreen(
                        module: widget.module,
                        labelWidth: widget.labelWidth,
                      )),
            );
          },
        ));
      }
      if (widget.module.globalSearch && widget.dataTableImplementation == DataTableImplementation.SyncfusionDataTable) {
        result.add(IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            List<DocumentSnapshot> allDocs = await keyDataTable.currentState!.loadAll();
            showSearch(context: context, delegate: _Search(parentState: this, allDocs: allDocs));
          },
        ));
      }

      return result;
    }

    print("build admin");
    List<Widget> leading = getLeading();
    return FutureBuilder(
        future: initAdmin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          return Scaffold(
            appBar: AppBar(
              backgroundColor: DashboardMainScreen.dashboardTheme?.appBar2BackgroundColor ?? Theme.of(context).secondaryHeaderColor,
              title: Text(widget.module.title),
              leadingWidth: leading.length * 40,
              leading: Row(children: leading),
              actions: widget.module.columns.map<Widget>((ColumnModule columnModule) {
                    if (columnModule.filter) {
                      if (filtro.containsKey(columnModule.field) == false) {
                        filtro[columnModule.field] = "";
                      }
                      return Row(children: [
                        columnModule.type.getFilterContent(context, filtro[columnModule.field], columnModule, (val) {
                          setState(() {
                            filtro[columnModule.field] = val;
                          });
                        })
                      ]);
                    } else
                      return Container();
                  }).toList() +
                  getActions(),
            ),
            body: getDataTable(context),
          );
        });
  }

  doBorrar(BuildContext context, DocumentReference ref, Function postDelete) {
    final SweetSheet _sweetSheet = SweetSheet();
    _sweetSheet.show(
      context: context,
      title: Text("¿Está seguro de borrar el elemento?"),
      description: Text("Esta acción no podrá deshacerse después"),
      color: SweetSheetColor.DANGER,
      icon: Icons.delete,
      positive: SweetSheetAction(
        onPressed: () {
          ref.delete();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('El elemento ha sido borrado'),
            duration: Duration(seconds: 2),
          ));
          postDelete();
        },
        title: 'Borrar',
      ),
      negative: SweetSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          return;
        },
        title: 'Cancelar',
      ),
    );
  }
}

class _Search extends SearchDelegate {
  final AdminScreenState parentState;
  final List<DocumentSnapshot> allDocs;

  _Search({required this.parentState, required this.allDocs});

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        },
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [];

  @override
  Widget buildSuggestions(BuildContext context) {
    print("buildSuggestions");

    List<DocumentSnapshot> suggesstions = [];
    for (DocumentSnapshot doc in allDocs) {
      for (var column in parentState.widget.module.columns) {
        if (doc.hasFieldAdm(column.field)) {
          String value = column.type.getSyncStringContent(doc, column);

          bool encontrado = value.toLowerCase().contains(query.toLowerCase());
          if (encontrado) {
            suggesstions.add(doc);
            break;
          }
        }
      }
    }
    return ListView.builder(
        itemCount: suggesstions.length,
        itemBuilder: (context, index) {
          final suggestion = suggesstions[index];
          List<String> suggestionText = [];
          parentState.widget.module.fieldsForShowInSearchResult.forEach((fieldName) {
            ColumnModule column = parentState.widget.module.columns.where((col) => col.field == fieldName).first;

            suggestionText.add(column.type.getSyncStringContent(suggestion, column));
            // suggestion.getFieldAdm(fieldName, "").toString());
          });
          return ListTile(
            title: Text(suggestionText.join(" - ")),
            onTap: () {
              /*query = suggestion;
              */
              close(context, null);
              parentState.showDetalleObject(suggestion);
            },
          );
        });
  }

  @override
  Widget buildResults(BuildContext context) => Center(
        child: Text(
          query, // query will hold user selected search query
        ),
      );
}
