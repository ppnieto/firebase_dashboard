import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/components/syncfusion_datasource.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class AdminController extends GetxController {
  late int pageSize;
  final DashboardModule module;
  final Map<String, dynamic>? filtroInicial;

  AdminController({required this.module, this.filtroInicial = const {}}) {
    this.pageSize = module.rowsPerPage;
    Get.log('init AdminController ${module.name}');
    Get.put(this);
  }

  bool canSelect = false;

  double minWidth = 5;
  String? _orderBy;
  List<DocumentSnapshot> _documents = <DocumentSnapshot>[];
  List<DocumentSnapshot> _allDocuments = <DocumentSnapshot>[];
  Map<DocumentSnapshot, List<String>> _searchIndex = {};
  String? _globalSearch;
  Map<String, dynamic> filtro = {};

  bool sortAscending = true;
  int? sortColumnIndex;
  List<DocumentSnapshot> rowsSelected = <DocumentSnapshot>[];
  RxList<String> deleteEnabled = <String>[].obs;
  StreamSubscription<QuerySnapshot>? dataSubscription;
  bool finalAlcanzado = false;
  Map<String, double> _columnWidths = {};

  Map<ColumnModule, bool> visibleColumns = <ColumnModule, bool>{};

  List<ColumnModule> columns = [];
  SyncfusionDataSource? _datagridSource;
  bool freezeLastColumn = false;

  SyncfusionDataSource? get datagridSource => _datagridSource;

  static ButtonLocation buttonLocation = GetStorage().read('button_location').toString().toButtonLocation();
  static ButtonAction buttonAction = GetStorage().read('button_action').toString().toButtonAction();

  Map<String, double> get columnWidths => _columnWidths;

  get box => GetStorage(module.name);

  @override
  void onInit() async {
    super.onInit();

    await initAdmin();
  }

  @override
  void onClose() {
    super.onClose();
    dataSubscription?.cancel();
    dataSubscription = null;
  }

  void toggleButtonAction() {
    buttonAction = buttonAction == ButtonAction.Large ? ButtonAction.Short : ButtonAction.Large;
    GetStorage gs = GetStorage();
    gs.write('button_action', buttonAction.toString());
    gs.save();
    update();
  }

  void toggleButtonLocation() {
    if (buttonLocation == ButtonLocation.Floating) {
      buttonLocation = ButtonLocation.ActionBar;
    } else if (buttonLocation == ButtonLocation.ActionBar) {
      buttonLocation = ButtonLocation.Bottom;
    } else {
      buttonLocation = ButtonLocation.Floating;
    }

    // no usar box, esto es para todas las instancias de admin
    GetStorage gs = GetStorage();
    gs.write('button_location', buttonLocation.toString());
    gs.save();
    update();
  }

  List<DocumentSnapshot> get docs => module.doFilter != null ? module.doFilter!(_documents) : _documents;

  set globalSearch(String search) {
    _globalSearch = search;
    _doGlobalSearch();
  }

  String get globalSearch => _globalSearch ?? "";

  void toggleSelect() {
    canSelect = !canSelect;
    if (!canSelect) {
      rowsSelected.clear();
    }
    update();
  }

  Future<bool> initAdmin() async {
    if (filtroInicial != null) {
      filtro = filtroInicial!;
    }

    _orderBy = module.orderBy;
    canSelect = module.canSelect;
    rowsSelected = <DocumentSnapshot>[];
    _documents = <DocumentSnapshot>[];
    finalAlcanzado = false;

    await GetStorage.init(module.name);

    try {
      _readColumnVisibility();
      _readColumnWidths();
      await _preloadReferences();
    } catch (e) {
      print("error: ");
      print(e);
    }

    reinit();

    return true;
  }

  void reinit() {
    columns = getColumns();
    _datagridSource = SyncfusionDataSource(columns: columns, module: module, controller: this);
    finalAlcanzado = false;
    nextPage();
  }

  List<ColumnModule> getColumns() {
    List<ColumnModule> columns = List.from(module.columns.where((column) {
      return visibleColumns.containsKey(column) && visibleColumns[column] == true && column.listable;
    }));

    if (module.canRemove || module.getActions != null) {
      freezeLastColumn = true;
      columns.add(ColumnModule(
          field: "_acciones",
          label: "",
          canSort: false,
          filter: false,
          width: module.actionColumnWidth,
          type: FieldTypeWidget(
            builder: (context, object, inList) {
              return Theme(
                  data: Theme.of(context).copyWith(
                      iconButtonTheme: IconButtonThemeData(style: ButtonStyle(iconColor: MaterialStatePropertyAll(Theme.of(context).primaryColor)))),
                  child: ListView(
                    padding: EdgeInsets.only(left: 20),
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      ...module.getActions != null ? module.getActions!(object!, context) : [],
                      if (module.canRemove && module.deleteDisabled)
                        Obx(() => deleteEnabled.contains(object!.reference.path)
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  doBorrar(context, object, () {});
                                },
                              )
                            : const SizedBox.shrink()),
                      if (module.canRemove && !module.deleteDisabled && module.canRemoveInList)
                        IconButton(
                          icon: Icon(Icons.delete),
                          tooltip: "Borrar",
                          onPressed: () {
                            doBorrar(context, object!, () {});
                          },
                        ),
                      //SizedBox(width: 15)
                    ].spacing(5),
                  ));
            },
          )));
    }
    return columns;
  }

  void _readColumnWidths() {
    if (box.hasData('columnWidths')) {
      try {
        _columnWidths = Map<String, double>.from(box.read('columnWidths'));
      } on Exception catch (e) {
        print("exception getting column widths");
        print(e);
      }
    } else {
      _columnWidths = {for (var v in module.columns.where((element) => element.width != null)) v.field: v.width!};
    }
  }

  void _readColumnVisibility() {
    Iterable<String> keys = box.getKeys();
    String key = 'admin_columns';
    if (keys.contains(key)) {
      List<String> sel = List<String>.from(box.read(key));
      visibleColumns = <ColumnModule, bool>{for (var column in module.columns) column: sel.contains(column.field)};
    } else {
      visibleColumns = <ColumnModule, bool>{for (var column in module.columns) column: true};
    }
  }

  void clearColumnWidths() {
    box.remove('columnWidths');
    _readColumnWidths();
    this.update();
  }

  void saveColumnWidths() {
    box.write('columnWidths', _columnWidths);
    box.save();
    update();
  }

  void filterResultsAndUpdate(List<DocumentSnapshot> docs) {
    Iterable<DocumentSnapshot> tmpList = List<DocumentSnapshot>.from(docs);

    for (MapEntry filterEntry in filtro.entries) {
      if (filterEntry.value != null && filterEntry.value.toString().isNotEmpty) {
        print("   add filter " + filterEntry.key + " = " + filterEntry.value.toString());
        if (filterEntry.value is String) {
          print("    string lo implemento sobre la lista de docs");
          tmpList = tmpList.where((element) => element.get(filterEntry.key).toString().contains(filterEntry.value));
        }
      }
    }
    _documents.clear();
    _documents.addAll(tmpList);
    updateData();
  }

  void updateData() async {
    _datagridSource = SyncfusionDataSource(columns: columns, module: module, controller: this);
    await _datagridSource?.buildDataGridRows();
    update();
    update(["listado"]);
  }

  void setFilter(Map<String, dynamic> f) {
    Get.log("set filter $f");
    filtro = f;
    initAdmin();
    update();
    update(["listado"]);
  }

  void nextPage() {
    Get.log('nextPage');
    if (finalAlcanzado) {
      Get.log('final alzanzado!!!!');
      return;
    }

    final int limit = pageSize + docs.length;
    Get.log('nextPage limit = $limit');
    dataSubscription?.cancel();
    dataSubscription = getQuery().limit(limit).snapshots().listen((value) {
      print("AdminController::listenStream ${value.docs.length}");
      _allDocuments.clear();
      _allDocuments.addAll(value.docs);

      filterResultsAndUpdate(value.docs);

      if (value.docs.length < limit) {
        finalAlcanzado = true;
      }
    });

    dataSubscription?.onError((error) {
      Get.printError(info: "error obteniendo datos");
      print(error);
    });
  }

  void setColumnaSeleccionada(ColumnModule cm, bool value) {
    visibleColumns[cm] = value;
    List<String> values = visibleColumns.entries.where((entry) => entry.value).map((entry) => entry.key.field).toList();
    box.write('admin_columns', values);
    box.save();
    reinit();
    update();
  }

  Future<void> _preloadReferences() async => module.columns.forEach((column) => column.type.preloadData());

  CollectionReference getCollectionReference() {
    if (module.collection != null) {
      return FirebaseFirestore.instance.collection(module.collection!);
    } else {
      if (module.getCollection != null) {
        return module.getCollection!();
      } else {
        if (module.getQueryCollection != null) {
          Query queryCollection = module.getQueryCollection!();
          if (queryCollection is CollectionReference) {
            return queryCollection;
          }
        }
      }
    }
    throw Exception("No puedo encontrar coleccion para modulo " + module.name);
  }

  Query getQueryCollection() {
    if (module.getQueryCollection != null) {
      return module.getQueryCollection!();
    } else {
      String collection = module.collection ?? "";
      return FirebaseFirestore.instance.collection(collection);
    }
  }

  Query addFilters(Map<String, dynamic> filtro, Query query) {
    Query result = query;
    for (MapEntry filterEntry in filtro.entries) {
      if (filterEntry.value != null && filterEntry.value.toString().isNotEmpty) {
        if (filterEntry.value is String == false) {
          result = result.where(filterEntry.key, isEqualTo: filterEntry.value);
        }
      }
    }
    return result;
  }

  void _doSearchIndex() {
    for (DocumentSnapshot doc in _allDocuments) {
      List<String> values = [];
      for (var column in module.columns) {
        if (doc.hasFieldAdm(column.field)) {
          String value = column.type.getValue(doc, column).toString();
          values.add(value);
        }
      }
      _searchIndex[doc] = values;
    }
  }

  Future<void> _doGlobalSearch() async {
    if (finalAlcanzado == false) {
      _allDocuments = await loadAll();
    }
    if (_searchIndex.isEmpty) {
      _doSearchIndex();
    }
    List<DocumentSnapshot> result = [];
    for (DocumentSnapshot doc in _allDocuments) {
      List<String> terminos = _searchIndex[doc] ?? [];
      for (var termino in terminos) {
        bool encontrado = termino.toLowerCase().contains(_globalSearch!.toLowerCase());
        if (encontrado) {
          result.add(doc);
          break;
        }
      }
    }
    filterResultsAndUpdate(result);
  }

  Future<List<DocumentSnapshot>> loadAll() async {
    Query query = getQuery();
    QuerySnapshot qs = await query.get();
    finalAlcanzado = true;
    return qs.docs;
  }

  showDetalleObject(BuildContext context, object) {
    if (module.canEdit) {
      DashboardService.instance.showDetalle(
        object: object,
        module: module,
        canDelete: deleteEnabled.contains(object.reference.path),
      );
    }
  }

  Query getQuery() {
    Query query = getQueryCollection();
    query = addFilters(filtro, query);
    if (module.addFilter != null) {
      query = module.addFilter!(query);
    }

    if (_orderBy != null) {
      query = query.orderBy(_orderBy!);
    }

    if (module.reverseOrderBy != null) {
      query = query.orderBy(module.reverseOrderBy!, descending: true);
    }
    return query;
  }

  doBorrar(BuildContext context, DocumentSnapshot object, Function postDelete) {
    if (module.deleteDisabled && !deleteEnabled.contains(object.reference.path)) {
      // esto no debe darse
      Get.snackbar("Atención", "No se puede borrar el elemento",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Theme.of(context).primaryColor, colorText: Colors.white, margin: EdgeInsets.all(20));
      return;
    }
    DashboardUtils.confirm(
        context: context,
        textPos: "Borrar",
        onPos: () {
          object.reference.delete();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("El elemento ha sido borrado"),
          ));
          if (module.onRemove != null) {
            module.onRemove!(object);
          }
          postDelete();
        },
        title: "¿Está seguro de borrar el elemento?",
        description: "Esta acción no podrá deshacerse después");
  }

  void multiselectRow(BuildContext context, DocumentSnapshot object, bool add) {
    if (add) {
      rowsSelected.add(object);
    } else {
      rowsSelected.removeWhere((obj) => obj.reference.path == object.reference.path);
    }
    update(["toolbar", "rowsSelected"]);
  }

  void selectRow(BuildContext context, DocumentSnapshot object) {
    rowsSelected.clear();
    rowsSelected.add(object);
    update(["toolbar", "rowsSelected"]);
  }

  void unselectAll() {
    rowsSelected.clear();
    update(["toolbar", "rowsSelected"]);
  }

  void exportExcel(BuildContext context) async {
    await DashboardUtils.loading(context, "Por favor espere...");
    try {
      _allDocuments = await loadAll();

      final xlsio.Workbook workbook = new xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      List<xlsio.ExcelDataRow> rows = [];

      List<ColumnModule> columnasExportables = module.columns.where((e) => e.excellable).toList();

      for (var doc in _allDocuments) {
        List<xlsio.ExcelDataCell> cells = [];
        for (var column in columnasExportables) {
          var value = column.type.getValue(doc, column);
          if (value is Timestamp) {
            value = DateFormat('dd/MM/yyyy hh:MM').format(value.toDate());
          } else {
            value = value.toString();
          }
          cells.add(xlsio.ExcelDataCell(value: value, columnHeader: column.label));
        }

        rows.add(xlsio.ExcelDataRow(cells: cells));
      }
      if (rows.isNotEmpty) {
        sheet.importData(rows, 1, 1);
      }
      List<int> bytes = workbook.saveAsStream();
      String suffix = DateFormat('yyyyMMdd').format(DateTime.now());
      String fileName = module.name + '_$suffix.xls';
      DashboardUtils.download(fileName, bytes);
    } finally {
      Navigator.of(context).pop();
    }
  }
}

enum ButtonLocation { Floating, ActionBar, Bottom }

enum ButtonAction { Short, Large }

extension _BL on String {
  ButtonLocation toButtonLocation() {
    // default
    // if (this == _ButtonLocation.Floating.toString()) return _ButtonLocation.Floating;
    if (this == ButtonLocation.ActionBar.toString()) return ButtonLocation.ActionBar;
    if (this == ButtonLocation.Bottom.toString()) return ButtonLocation.Bottom;
    return ButtonLocation.Floating;
  }
}

extension _BA on String {
  ButtonAction toButtonAction() {
    if (this == ButtonAction.Large.toString()) return ButtonAction.Short;
    return ButtonAction.Short;
  }
}
