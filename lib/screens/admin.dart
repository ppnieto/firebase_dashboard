import 'dart:developer';

import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/screens/detalle.dart';
import 'package:firebase_dashboard/components/syncfusion_datatable.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:get/get.dart';
import 'package:anim_search_bar/anim_search_bar.dart';

class AdminScreen extends StatelessWidget {
  final bool showScaffoldBack;
  final double minWidth;
  final double labelWidth;
  final Module module;
  final Map<String, dynamic>? filtroInicial;

  AdminScreen({
    Key? key,
    this.showScaffoldBack = false,
    this.minWidth = 200,
    this.labelWidth = 120,
    required this.module,
    this.filtroInicial,
  }) : super(key: key) {}

  final scrollController = ScrollController();

  Widget getDataTable(BuildContext context) {
    return SyncfusionDataTable(module: module);
  }

  void addRecord() {
    {
      AdminController controller = Get.find<AdminController>(tag: module.name);
      Get.to(
          () => DetalleScreen(
                module: controller.module,
                labelWidth: labelWidth,
              ),
          id: DashboardMainScreen.dashboardKeyId);
    }
  }

  List<Widget> getLeading(BuildContext context) {
    AdminController controller = Get.find<AdminController>(tag: module.name);

    return [
      SizedBox(width: 10),
      if (Navigator.of(context).canPop())
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      if (module.showColumnSelection && module.compactColumnSelection)
        PopupMenuButton(
          icon: Icon(Icons.list),
          itemBuilder: (context) {
            return controller.module.columns.where((element) => element.listable).map((ColumnModule columnModule) {
              return PopupMenuItem(
                  child: Obx(() => CheckboxListTile(
                        title: Text(columnModule.label),
                        value: controller.visibleColumns[columnModule] ?? false,
                        onChanged: (value) {
                          controller.setColumnaSeleccionada(columnModule, value!);
                          Navigator.of(context).pop();
                        },
                      )));
            }).toList();
          },
        ),
      if (module.showColumnSelection && !module.compactColumnSelection)
        IconButton(
            icon: Icon(FontAwesomeIcons.listUl),
            onPressed: () async {
              var items = controller.module.columns.where((element) => element.listable).map((ColumnModule columnModule) {
                return MultiSelectItem(columnModule.field, columnModule.label);
              }).toList();
              var initialValue = controller.visibleColumns.entries.where((element) => element.value).map<String>((e) => e.key.field).toList();

              print("items $items");
              print("initialValue $initialValue");

              await showDialog(
                context: context,
                builder: (ctx) {
                  return MultiSelectDialog<String>(
                    items: items,
                    initialValue: initialValue,
                    searchable: false,
                    confirmText: Text('Aceptar'),
                    cancelText: Text('Cancelar'),
                    title: Text("Seleccione las columnas para mostrar"),
                    onConfirm: (Iterable<String> values) {
                      //setState(() {
                      for (var columna in controller.visibleColumns.entries) {
                        if (values.contains(columna.key.field)) {
                          controller.setColumnaSeleccionada(columna.key, true);
                        } else {
                          controller.setColumnaSeleccionada(columna.key, false);
                        }
                      }
                    },
                  );
                },
              );
            }),
      IconButton(
          onPressed: () {
            DashboardUtils.confirm(
                context: context,
                textPos: "Reestablecer",
                color: SweetSheetColor.NICE,
                onPos: () {
                  controller.clearColumnWidths();
                  Navigator.of(context).pop();
                },
                title: "Atención",
                description: "¿Desea restablecer el ancho de las columnas?");
          },
          icon: Icon(Icons.width_normal))
    ];
  }

/*
  Widget getGlobalSearch(BuildContext context) {
    AdminController controller = Get.find<AdminController>(tag: module.name);

    Color
        highlightColor = //context.findAncestorStateOfType<DashboardMainScreenState>()?.widget.theme?.appBar1TextColor ??
        Theme.of(context).primaryColor;

    return Container(
      width: 280,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).cardColor,
          suffixIcon: Icon(Icons.search, color: highlightColor),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
            borderRadius: BorderRadius.circular(6.0),
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: highlightColor, width: 2.0)),
          hintText: "Buscar...",
          hintStyle: TextStyle(color: highlightColor),
          contentPadding: EdgeInsets.all(10),
        ),
        style: TextStyle(color: highlightColor),
        onChanged: (value) {
          //setState(() {
          controller.globalSearch = value;
          //});
        },
      ),
    );
  }
*/
  getActions(BuildContext context) {
    AdminController controller = Get.find<AdminController>(tag: module.name);
    TextEditingController searchController = TextEditingController();
    searchController.addListener(() {
      controller.globalSearch = searchController.text;
    });

    List<Widget> result = [];

    if (controller.module.getScaffoldActions != null) {
      result.addAll(controller.module.getScaffoldActions!(context));
    }
/*
    if (controller.module
        .globalSearch /* && dataTableImplementation == DataTableImplementation.AdminDataTable*/) {
      result.add(getGlobalSearch(context));
    }*/

    if (module.canRemove) {
      result.add(Obx(() {
        AdminController adminController = Get.find<AdminController>(tag: module.name);
        bool deleteDisabled =
            module.deleteDisabled && controller.rowsSelected.any((element) => !adminController.deleteEnabled.contains(element.reference.path));
        return controller.rowsSelected.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                icon: Icon(Icons.delete),
                onPressed: deleteDisabled
                    ? null
                    : () {
                        // falta comprobar si rows selected pueden ser eliminados
                        /*
                if (module.deleteDisabled &&
                    controller.rowsSelected.any((element) => !adminController.deleteEnabled.contains(element.reference.path))) {
                  Get.snackbar("Atención", "No se puede borrar la selección porque algunos elementos no se pueden eliminar",
                      duration: Duration(seconds: 2), snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(20));
                } else {
                  */
                        DashboardUtils.confirm(
                            context: context,
                            textPos: "Borrar",
                            onPos: () {
                              controller.rowsSelected.forEach((element) {
                                element.reference.delete();
                                if (module.onRemove != null) {
                                  module.onRemove!(element);
                                }
                              });
                              controller.rowsSelected.clear();
                              Navigator.of(context).pop();
                              //Get.nestedKey(DashboardMainScreen.dashboardKeyId)?.currentState?.pop();
                              Get.snackbar("Atención", "Los elementos han sido borrados",
                                  duration: Duration(seconds: 2), snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(20));
                            },
                            title: "Atención",
                            description: "¿Está seguro de borrar " + controller.rowsSelected.length.toString() + " elementos?");
                      }
                //},

                );
      }));
    }

    result.add(IconButton(
        onPressed: () {
          AdminController controller = Get.find<AdminController>(tag: module.name);
          controller.toggleSelect();
        },
        icon: Icon(Icons.checklist)));

    if (controller.module.exportExcel) {
      result.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(FontAwesomeIcons.fileExcel),
            onPressed: () {
              controller.exportExcel(context);
            },
          )));
    }
    if (controller.module.canAdd && !controller.module.floatingButtons) {
      result.add(IconButton(padding: EdgeInsets.all(0), icon: Icon(Icons.add), onPressed: () => addRecord()));
    }
    if (controller.module.globalSearch) {
      /*
      result.add(IconButton(
        icon: Icon(Icons.search),
        onPressed: () async {
          List<DocumentSnapshot> allDocs = await controller.loadAll();
          showSearch(context: context, delegate: _Search(allDocs: allDocs, module: module));
        },
      ));
      */
      result.add(Theme(
          data: ThemeData(
              inputDecorationTheme: InputDecorationTheme(
            /*border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, */ contentPadding: EdgeInsets.all(3),
          )),
          child: Center(
              child: Container(
            height: 42,
            child: AnimSearchBar(
              width: 300,
              color: Theme.of(context).primaryColor,
              textFieldColor: Theme.of(context).canvasColor,
              textFieldIconColor: Theme.of(context).colorScheme.secondary,
              searchIconColor: Theme.of(context).canvasColor,
              autoFocus: true,
              helpText: "Buscar",
              textController: searchController,
              onSuffixTap: () {
                searchController.text = "";
              },
              onSubmitted: (text) {
                print("search for $text");
              },
            ),
          ))));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminController>(
        init: AdminController(module: module, filtroInicial: filtroInicial),
        tag: module.name,
        builder: (controller) {
          List<Widget> leading = getLeading(context);
          return Scaffold(
            appBar: AppBar(
              backgroundColor: DashboardMainScreen.dashboardTheme?.appBar2BackgroundColor ?? Theme.of(context).secondaryHeaderColor,
              title: Text(controller.module.title),
              leadingWidth: leading.length * 40,
              leading: Row(children: leading),
              actions: getActions(context),
            ),
            floatingActionButton: module.floatingButtons
                ? FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => addRecord(),
                  )
                : null,
            body: getDataTable(context),
          );
        });
  }
}
