import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:firebase_dashboard/components/syncfusion_datatable.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/controllers/detalle.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:sweetsheet/sweetsheet.dart';

class AdminScreen extends StatelessWidget {
  final bool showScaffoldBack;
  final double minWidth;
  final double labelWidth;
  final DashboardModule module;
  final String? title;
  final Map<String, dynamic>? filtroInicial;

  AdminScreen({
    Key? key,
    this.showScaffoldBack = false,
    this.minWidth = 200,
    this.labelWidth = 120,
    this.title,
    required this.module,
    this.filtroInicial,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final scrollController = ScrollController();

  void addRecord(BuildContext context, AdminController controller) =>
      DashboardService.instance.showDetalle(module: controller.module);

  List<Widget> getLeading(BuildContext context, AdminController controller) {
    bool showColumnSelectorInPopupMenu =
        module.showColumnSelection && module.compactColumnSelection && !Responsive.isMobile(context);
    return [
      if (showColumnSelectorInPopupMenu)
        PopupMenuButton(
          icon: Icon(Icons.list),
          tooltip: "Selección de columnas",
          itemBuilder: (context) {
            return controller.module.columns.where((element) => element.listable).map((ColumnModule columnModule) {
              return PopupMenuItem(
                  child: CheckboxListTile(
                title: Text(columnModule.label),
                value: controller.visibleColumns[columnModule] ?? false,
                onChanged: (value) {
                  controller.setColumnaSeleccionada(columnModule, value!);
                  Navigator.of(context).pop();
                },
              ));
            }).toList();
          },
        ),
      if (!showColumnSelectorInPopupMenu)
        IconButton(
            icon: Icon(FontAwesomeIcons.listUl),
            tooltip: "Selección de columnas",
            onPressed: () async {
              var items =
                  controller.module.columns.where((element) => element.listable).map((ColumnModule columnModule) {
                return MultiSelectItem(columnModule.field, columnModule.label);
              }).toList();
              var initialValue = controller.visibleColumns.entries
                  .where((element) => element.value)
                  .map<String>((e) => e.key.field)
                  .toList();

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
                        controller.setColumnaSeleccionada(columna.key, values.contains(columna.key.field));
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
                },
                title: "Atención",
                description: "¿Desea restablecer el ancho de las columnas?");
          },
          tooltip: "Reestablecer columnas",
          icon: Icon(Icons.width_normal))
    ];
  }

  List<Widget> getActions(BuildContext context, AdminController controller) {
    List<Widget> result = [];
    bool deleteDisabled = module.deleteDisabled &&
        controller.rowsSelected.any((element) => !controller.deleteEnabled.contains(element.reference.path));

    if (module.canRemove) {
      if (controller.rowsSelected.isNotEmpty) {
        result.add(IconButton(
            icon: Icon(Icons.delete),
            tooltip: "Borrar",
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

                          Get.snackbar("Atención", "Los elementos han sido borrados",
                              duration: Duration(seconds: 2),
                              snackPosition: SnackPosition.BOTTOM,
                              margin: EdgeInsets.all(20));
                        },
                        title: "Atención",
                        description:
                            "¿Está seguro de borrar " + controller.rowsSelected.length.toString() + " elementos?");
                  }
            //},

            ));
      }
    }

    if (controller.module.getScaffoldActions != null) {
      result.addAll(controller.module.getScaffoldActions!(context));
    }

    if (module.canSelect || module.canRemove)
      result.add(IconButton(
          onPressed: () {
            controller.toggleSelect();
          },
          tooltip: "Seleccionar",
          icon: Icon(Icons.checklist)));

    if (controller.module.exportExcel) {
      result.add(IconButton(
        tooltip: "Exportar",
        icon: Icon(FontAwesomeIcons.fileExcel),
        onPressed: () {
          controller.exportExcel(context);
        },
      ));
    }
    if (controller.module.canAdd && AdminController.buttonLocation == ButtonLocation.ActionBar) {
      result.add(IconButton(icon: Icon(Icons.add), tooltip: "Añadir", onPressed: () => addRecord(context, controller)));
    }
    if (controller.module.globalSearch) {
      result.add(AppBarSearchButton(
        toolTipLastText: "Última búsqueda: ",
        toolTipStartText: "Click para buscar",
      ));
    }

    result.add(IconButton(
      icon: Icon(Icons.settings),
      tooltip: "Ajustes",
      onPressed: () {
        _key.currentState!.openEndDrawer();
      },
    ));

    return result;
  }

  Widget getSidebar(AdminController adminController) {
    return Container(
      width: 400,
      color: Colors.white,
      child: StatefulBuilder(builder: (context, innerSetState) {
        return SettingsList(
          sections: [
            SettingsSection(
              title: Text('Botones de accion'),
              tiles: <SettingsTile>[
                SettingsTile(
                  leading: Icon(Icons.smart_button),
                  title: Text('Botones de acción'),
                  description: Text(AdminController.buttonLocation.description()),
                  onPressed: (context) {
                    adminController.toggleButtonLocation();
                  },
                ),
                SettingsTile(
                  leading: Icon(Icons.smart_button),
                  title: Text("Botones de la barra"),
                  description: Text(AdminController.buttonAction.description()),
                  onPressed: (context) {
                    adminController.toggleButtonAction();
                  },
                )
              ],
            ),
          ],
        );
      }),
    );
  }

  PopupMenuItem getPopupMenu(Widget widget) {
    if (widget is IconButton) {
      return PopupMenuItem(
          value: widget,
          child: ListTile(leading: widget.icon, title: widget.tooltip != null ? Text(widget.tooltip!) : null));
    } else if (widget is AppBarSearchButton) {
      return PopupMenuItem(value: widget, child: ListTile(leading: const Icon(Icons.search), title: Text("Buscar")));
    } else {
      return PopupMenuItem(child: widget);
    }
  }

  List<Widget> processActions(BuildContext context, List<Widget> actions) {
    if (!Responsive.isMobile(context)) {
      return actions;
    } else {
      return [
        PopupMenuButton(
            onSelected: (value) {
              if (value is IconButton) {
                value.onPressed?.call();
              } else if (value is AppBarSearchButton) {
                AppBarWithSearchSwitch.of(context)?.startSearch();
              }
            },
            itemBuilder: (ctx) => actions.map((w) => getPopupMenu(w)).toList())
      ];
    }
  }

  @override
  Widget build(context) {
    return GetBuilder<AdminController>(
        init: AdminController(module: module, filtroInicial: filtroInicial),
        tag: module.name,
        global: false,
        builder: (controller) {
          String _title = controller.module.title;
          if (title != null) {
            _title += " / ${title}";
          }

          return Scaffold(
            key: _key,
            appBar: AppBarWithSearchSwitch(
              onChanged: (text) {
                controller.globalSearch = text;
              },
              onClosed: () {
                print("on closed search");
                controller.update(['toolbar']);
              },
              appBarBuilder: (context) {
                return PreferredSize(
                    preferredSize: const Size(double.infinity, kToolbarHeight),
                    child: GetBuilder<AdminController>(
                      id: "toolbar",
                      tag: module.name,
                      init: controller,
                      builder: (controller) {
                        return AppBar(
                          title: Text(_title),
                          actions: processActions(
                              context,
                              getActions(context, controller) +
                                  //<Widget>[] +
                                  getLeading(context, controller)),
                        );
                      },
                    ));
              },
              fieldHintText: "Buscar",
              tooltipForCloseButton: "Cerrar búsqueda",
              tooltipForClearButton: "Limpiar",
            ),
            endDrawer: getSidebar(controller),
            bottomNavigationBar: AdminController.buttonLocation == ButtonLocation.Bottom && module.canAdd
                ? ElevatedButton.icon(
                        icon: Icon(Icons.add), onPressed: () => addRecord(context, controller), label: Text("Añadir"))
                    .paddingAll(24)
                : null,
            floatingActionButton: AdminController.buttonLocation == ButtonLocation.Floating && module.canAdd
                ? FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => addRecord(context, controller),
                  ).paddingAll(24)
                : null,
            body: SyncfusionDataTable(module: module),
          );
        });
  }
}

extension _BLTS on ButtonLocation {
  String description() {
    return this == ButtonLocation.Floating
        ? "Flotante"
        : this == ButtonLocation.ActionBar
            ? "Barra de acciones"
            : "Inferior";
  }
}

extension _BATS on ButtonAction {
  String description() {
    return this == ButtonAction.Short ? "Compactos" : "Completos";
  }
}
