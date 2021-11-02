import 'dart:convert';

import 'package:dashboard/admin/admin_modules.dart';
import 'package:dashboard/dashboard.dart';
import 'package:data_table_2/paginated_data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:excel/excel.dart';
import 'dart:html' as html; // or package:universal_html/prefer_universal/html.dart
import 'package:data_table_2/data_table_2.dart';

class AdminScreen extends StatefulWidget {
  final Module module;
  final bool showScaffoldBack;
  final bool selectPreEdit;
  final CollectionReference? collection;
  final double minWidth;

  AdminScreen({
    required this.module,
    this.showScaffoldBack = false,
    this.minWidth = 200,
    this.selectPreEdit = false,
    this.collection,
  });

  @override
  State<StatefulWidget> createState() => AdminScreenState();
}

enum TipoPantalla { listado, detalle, nuevo, confirmar }

class AdminScreenState extends State<AdminScreen> {
  // ignore: non_constant_identifier_names
  static bool USE_DATA_TABLE_V2 = true;

  int? indexSelected;
  late int rowsPerPage;
  String? _orderBy;
  List<DocumentSnapshot>? docs;
  String? globalSearch;
  TipoPantalla tipo = TipoPantalla.listado;
  DocumentSnapshot? detalle;
  Map<String, dynamic>? updateData;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> filtro = {};
  final scrollController = ScrollController();
  late Map<String, bool> columnasSeleccionadas = {};

  bool sortAscending = true;
  int? sortColumnIndex;

  @override
  void initState() {
    super.initState();

    _orderBy = widget.module.orderBy;

    rowsPerPage = widget.module.rowsPerPage;

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      String key = 'admin_columns_' + widget.module.name;
      if (prefs.containsKey(key)) {
        List<String> sel = prefs.getStringList(key)!;
        for (var col in widget.module.columns) {
          columnasSeleccionadas[col.field] = false;
        }
        for (var s in sel) {
          columnasSeleccionadas[s] = true;
        }
        String json = prefs.getString(key)!;
        print("json = ${json}");
        var tmp = jsonDecode(json);
      } else {
        for (var col in widget.module.columns) {
          columnasSeleccionadas[col.field] = true;
        }
      }
    });

    preloadReferences();
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
          String value = column.getStringContent(doc);
          bool encontrado = value.toLowerCase().contains(this.globalSearch!.toLowerCase());
          print("$value contains ${this.globalSearch} ? $encontrado");
          if (encontrado) {
            result.add(doc);
            break;
          }
        }
      }
    }
    this.docs = result;
  }

  getList() {
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

    return StreamBuilder(
      stream: query.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          print("shrink!!!!");
          return SizedBox.shrink();
        }

        docs = List.from(snapshot.data!.docs);

        if (widget.module.doFilter != null) {
          docs = widget.module.doFilter!(docs);
        }

        if (this.globalSearch != null) {
          doGlobalSearch();
        }

        if (widget.module.canSort && sortColumnIndex != null) {
          var column = widget.module.columns[sortColumnIndex!];
          this.docs?.sort((a, b) {
            var varA = a.getFieldAdm(column.field, '');
            var varB = b.getFieldAdm(column.field, '');

            if (varA is DocumentReference) {
              varA = column.type.preloadedData[varA.path];
            }
            if (varB is DocumentReference) {
              varB = column.type.preloadedData[varB.path];
            }

            return this.sortAscending ? varA?.compareTo(varB) : varB?.compareTo(varA);
          });
        }

        if (USE_DATA_TABLE_V2) {
          return PaginatedDataTable2(
              onPageChanged: (page) {
                print("onpagechanged... $page");
                setState(() {});
                //scrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.ease);
              },
              sortAscending: sortAscending,
              sortColumnIndex: sortColumnIndex,
              showCheckboxColumn: false,
              columnSpacing: 0.0,
              dataRowHeight: 38,
              minWidth: widget.minWidth,
              lmRatio: 1.8,
              autoRowsToHeight: true,
              columns: widget.module.columns
                      .where((element) =>
                          element.listable && this.columnasSeleccionadas.containsKey(element.field) && this.columnasSeleccionadas[element.field]!)
                      .map((column) {
                    return DataColumn2(
                      onSort: (int column, bool ascending) {
                        if (widget.module.canSort) {
                          setState(() {
                            sortAscending = ascending;
                            sortColumnIndex = column;
                          });
                        }
                      },
                      size: column.size,
                      label: Text(column.label),
                    );
                  }).toList() +
                  (widget.module.canRemove || widget.module.getActions != null ? [DataColumn2(label: SizedBox.shrink(), size: ColumnSize.L)] : []),
              source: MyDataTableSource(
                  docs: docs!,
                  context: context,
                  screen: this,
                  onTap: (index) {
                    setState(() {
                      detalle = docs![index];
                      updateData = detalle?.data() as Map<String, dynamic>?;
                      tipo = TipoPantalla.detalle;
                    });
                  },
                  showFields: this.columnasSeleccionadas));
        } else {
          return ListView(
            children: [
              PaginatedDataTable(
                  onPageChanged: (page) {
                    print("onpagechanged... $page");
                    scrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.ease);
                  },
                  showCheckboxColumn: false,
                  columnSpacing: 0.0,
                  dataRowHeight: 38,
                  columns: widget.module.columns
                          .where((element) =>
                              element.listable && this.columnasSeleccionadas.containsKey(element.field) && this.columnasSeleccionadas[element.field]!)
                          .map((column) {
                        return DataColumn2(
                          size: column.size,
                          label: Text(column.label),
                        );
                      }).toList() +
                      (widget.module.canRemove || widget.module.getActions != null
                          ? [DataColumn2(label: SizedBox.shrink(), size: ColumnSize.L)]
                          : []),
                  source: MyDataTableSource(
                      docs: docs!,
                      context: context,
                      screen: this,
                      onTap: (index) {
                        setState(() {
                          detalle = docs![index];
                          updateData = detalle?.data() as Map<String, dynamic>?;
                          tipo = TipoPantalla.detalle;
                        });
                      },
                      showFields: this.columnasSeleccionadas)),
            ],
          );
        }
      },
    );
  }

  getEditField(ColumnModule column) {
    column.type.setContext(context);
    Widget child = column.getEditContent(detalle!, updateData!, column, (value) {
      setState(() {
        updateData![column.field] = value;
        print("actualizamos campo ${column.field} => $value");
      });
    });

    if (column.showLabelOnEdit) {
      child = Row(children: [
        ConstrainedBox(constraints: BoxConstraints(minWidth: 120), child: Text(column.label)),
        SizedBox(width: 20),
        Expanded(child: child)
      ]);
    }

    return Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.width < responsiveDashboardWidth ? 5 : 20), child: child);
  }

  showError(e) {
    String message = "Error al guardar";
    if (e is FirebaseException) {
      print(e.code);
      if (e.code == "permission-denied") {
        message = "Error, no tiene permisos para realizar esta acción";
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ));
  }

  doGuardar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // ñapa para guardar el documentref /values/null como nulo!!!
      for (var entry in this.updateData!.entries) {
        if (entry.value is DocumentReference) {
          DocumentReference tmp = entry.value;
          if (tmp.path == FieldTypeRef.nullValue.path) {
            this.updateData![entry.key] = null;
          }
        }
      }

      bool isNew = tipo == TipoPantalla.nuevo;

      String? msgValidation;

      if (widget.module.validation != null) {
        msgValidation = await widget.module.validation!(isNew, this.updateData!);
      }

      bool doUpdate = true;
      if (widget.module.onSave != null) {
        doUpdate = widget.module.onSave!(tipo == TipoPantalla.nuevo, this.updateData);
      }
      if (msgValidation == null) {
        if (doUpdate) {
          if (!isNew) {
            detalle!.reference.update(this.updateData!).then((value) {
              if (widget.module.onUpdated != null) widget.module.onUpdated!(isNew, detalle!.reference);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Elemento guardado con éxito'),
                duration: Duration(seconds: 2),
              ));
              setState(() {
                this.tipo = TipoPantalla.listado;
              });
            }).catchError((e) {
              showError(e);
            });
          } else if (tipo == TipoPantalla.nuevo) {
            _getCollection().add(this.updateData!).then((value) {
              if (widget.module.onUpdated != null) widget.module.onUpdated!(isNew, value);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Elemento guardado con éxito'),
                duration: Duration(seconds: 2),
              ));
              setState(() {
                this.tipo = TipoPantalla.listado;
              });
            }).catchError((e) {
              showError(e);
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Elemento guardado con éxito'),
            duration: Duration(seconds: 2),
          ));
          setState(() {
            this.tipo = TipoPantalla.listado;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msgValidation),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  getDetail() => SingleChildScrollView(
        child: Card(
          elevation: 2,
          margin: MediaQuery.of(context).size.width >= responsiveDashboardWidth ? EdgeInsets.fromLTRB(64, 32, 64, 64) : EdgeInsets.all(5),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < responsiveDashboardWidth ? 32.0 : 5),
            child: Container(
                child: Builder(
                    builder: (context) => Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: widget.module.columns.map<Widget>((column) {
                              if (column.showOnEdit) {
                                return getEditField(column);
                              } else {
                                return Container();
                              }
                            }).toList())))),
          ),
        ),
      );

  getNuevo() => SingleChildScrollView(
        child: Card(
          elevation: 2,
          margin: EdgeInsets.fromLTRB(64, 32, 64, 64),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Builder(
                    builder: (context) => Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: widget.module.columns.map<Widget>((column) {
                                  if (column.showOnNew) {
                                    return getEditField(column);
                                  } else {
                                    return Container();
                                  }
                                }).toList() +
                                [])))),
          ),
        ),
      );

  getTitle() {
    return Text(widget.module.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold));
  }

  getConfirmar() => Center(
      child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(children: [Text("¿Está seguro que desea realizar la operación?"), TextButton(onPressed: () {}, child: Text("SI"))])));

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (tipo == TipoPantalla.listado) {
      content = getList();
    } else if (tipo == TipoPantalla.detalle) {
      content = getDetail();
    } else if (tipo == TipoPantalla.nuevo) {
      content = getNuevo();
    } else if (tipo == TipoPantalla.confirmar) {
      content = getConfirmar();
    } else
      content = Container();

    getLeading() {
      if (widget.showScaffoldBack) return null;
      if (tipo != TipoPantalla.listado) {
        return IconButton(
            icon: Icon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              setState(() {
                tipo = TipoPantalla.listado;
              });
            });
      } else {
        return IconButton(
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
                    //items: ['uno', 'dos'],
                    //initialValue: 'uno',
                    onConfirm: (values) {
                      setState(() {
                        columnasSeleccionadas.clear();
                        for (var value in values) {
                          columnasSeleccionadas[value] = true;
                        }

                        SharedPreferences.getInstance().then((SharedPreferences prefs) {
                          String key = 'admin_columns_' + widget.module.name;
                          prefs.setStringList(key, values);
                        });
                      });
                    },
                  );
                },
              );
            });
//        return Container();
      }
    }

    Widget getGlobalSearch() => Container(
          width: 280,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.search, color: Theme.of(context).canvasColor),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Theme.of(context).canvasColor, width: 2.0)),
              hintText: "Buscar...",
              hintStyle: TextStyle(color: Theme.of(context).canvasColor),
              contentPadding: EdgeInsets.all(10),
            ),
            style: TextStyle(color: Theme.of(context).canvasColor),
            onChanged: (value) {
              setState(() {
                this.globalSearch = value;
              });
            },
          ),
        );

    void exportExcel() {
      var excelFile = Excel.createExcel();
      String? sheetObjectName = excelFile.getDefaultSheet();
      Sheet sheetObject = excelFile[sheetObjectName!];

      if (docs != null) {
        // cabecera
        List<String> row = [];
        for (var column in widget.module.columns) {
          if (column.listable) {
            row.add(column.label);
          }
        }
        sheetObject.appendRow(row);

        // datos
        for (var doc in docs!) {
          row = [];
          for (var column in widget.module.columns) {
            if (column.listable) {
              row.add(column.type.getStringContent(doc, column));
            }
          }
          sheetObject.appendRow(row);
        }
      }
      var bytes = excelFile.encode();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      DateTime now = DateTime.now();
      String suffix = DateFormat('yyyyMMdd').format(now);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = widget.module.name + '_$suffix.xls';
      html.document.body!.children.add(anchor);

// download
      anchor.click();

// cleanup
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }

    getActions() {
      List<Widget> result = [];

      if (widget.module.globalSearch && tipo == TipoPantalla.listado) {
        result.add(getGlobalSearch());
      }

      if (tipo == TipoPantalla.listado && widget.module.exportExcel) {
        result.add(IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(FontAwesomeIcons.fileExcel),
          onPressed: () {
            exportExcel();
          },
        ));
      }
      if (tipo == TipoPantalla.listado && widget.module.canAdd) {
        result.add(IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              detalle = null;
              updateData = {};
              tipo = TipoPantalla.nuevo;
            });
          },
        ));
      }

      if (tipo == TipoPantalla.detalle || tipo == TipoPantalla.nuevo) {
        result.add(IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(FontAwesomeIcons.save),
          onPressed: () {
            doGuardar();
          },
        ));
      }
      if (tipo == TipoPantalla.detalle && widget.module.canRemove) {
        result.add(IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.delete),
          onPressed: () async {
            doBorrar(context, detalle!.reference, () {
              setState(() {
                tipo = TipoPantalla.listado;
              });
            });
          },
        ));
      }
      return result;
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          title: Text(widget.module.title),
          leading: getLeading(),
          actions: <Widget>[] +
              widget.module.columns.map<Widget>((ColumnModule columnModule) {
                if (columnModule.filter && tipo == TipoPantalla.listado) {
                  if (filtro.containsKey(columnModule.field) == false) {
                    filtro[columnModule.field] = "";
                  }
                  return Row(children: [
                    columnModule.getFilterContent(filtro[columnModule.field], (val) {
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
        body: content);
  }
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
        selected: screen.indexSelected == index,
        index: index,
        cells: module.columns
                .where((element) => element.listable && this.showFields.containsKey(element.field) && this.showFields[element.field]!)
                .map<DataCell>((column) {
              // set context
              column.type.setContext(context);
              return DataCell(column.getListContent(_object),
                  onTap: column.clickToDetail
                      ? () {
                          if (screen.widget.selectPreEdit && (screen.indexSelected == null || screen.indexSelected != index)) {
                            screen.setState(() {
                              screen.indexSelected = index;
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
