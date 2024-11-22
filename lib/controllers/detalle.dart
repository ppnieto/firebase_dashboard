import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/services/dashboard.dart';
import 'package:firebase_dashboard/field_types/field_type_base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetalleController extends GetxController {
  final DocumentSnapshot? object;
  final double labelWidth;
  final bool showLabel;
  final bool canDelete;
  final DashboardModule module;
  final int responsiveDashboardWidth = 1000;
  final Map<String, dynamic>? initialData;
  GlobalKey<FormState>? _formKey;

  Map<String, dynamic>? _updateData;
  StreamSubscription<DocumentSnapshot>? changesSubscription;

  DetalleController({this.object, required this.module, this.labelWidth = 120, this.showLabel = true, this.canDelete = true, this.initialData});

  @override
  void onInit() {
    super.onInit();
    _updateData = object?.data() as Map<String, dynamic>? ?? initialData ?? {};
    changesSubscription = object?.reference.snapshots().listen((value) {
      _updateData = value.data() as Map<String, dynamic>?;
      update();
    });

    if (module.onNew != null) {
      module.onNew!(_updateData);
    }
  }

  @override
  void onClose() {
    super.onClose();
    changesSubscription?.cancel();
  }

  void updateData(String fieldName, var value) {
    _updateData?.updateValueFor(keyPath: fieldName, value: value);
  }

  getEditField(BuildContext context, ColumnModule column) {
    Widget? child = column.type.getEditContent(context, object, _updateData!, column);

    if (child != null) {
      if (Responsive.isMobile(context)) {
        if (column.type.showLabel()) {
          child = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(column.label).paddingOnly(left: 5), child],
          ).paddingOnly(top: 5);
        }
        if (column.helpText != null) {
          child = Row(
            children: [
              Tooltip(
                  message: column.helpText!,
                  child: Icon(
                    Icons.help,
                    color: Theme.of(context).primaryColor,
                  )).paddingOnly(right: 5),
              Expanded(child: child)
            ],
          );
        }
      } else {
        if (column.showLabelOnEdit && showLabel) {
          child = Row(children: [
            ConstrainedBox(constraints: BoxConstraints(minWidth: labelWidth), child: Text(column.label)),
            if (column.helpText != null)
              Tooltip(
                  message: column.helpText!,
                  child: Icon(
                    Icons.help,
                    color: Theme.of(context).primaryColor,
                  )),
            SizedBox(width: 20),
            Expanded(child: child),
          ]);
        }
      }
      return Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.width < responsiveDashboardWidth ? 5 : 20), child: child);
    } else {
      return const SizedBox.shrink();
    }
  }

  getDetail(BuildContext context) => SingleChildScrollView(
        child: Card(
          //elevation: 5,
          //color: Theme.of(context).canvasColor,
          margin: MediaQuery.of(context).size.width >= responsiveDashboardWidth ? EdgeInsets.all(20) : EdgeInsets.all(5),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < responsiveDashboardWidth ? 32.0 : 5),
            child: Container(
                child: StreamBuilder(
                    stream: object?.reference.snapshots(),
                    builder: (context, snapshot) {
                      _formKey = GlobalKey<FormState>();
                      return Builder(
                          builder: (context) => Form(
                              key: _formKey,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: module.columns.map<Widget>((column) {
                                    if ((object == null && column.showOnNew) || (object != null && column.showOnEdit)) {
                                      return getEditField(context, column);
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }).toList() /* +
                                      <Widget>[
                                        if (AdminController.buttonLocation == ButtonLocation.Bottom)
                                          ElevatedButton.icon(onPressed: () => doGuardar(), icon: Icon(Icons.save), label: Text("Guardar"))
                                      ]*/
                                  )));
                    })),
          ),
        ),
      );

  CollectionReference _getCollection() {
    print("getCollection");
    // no usamos el AdminController por si es un detalle sin listado
    //AdminController adminController = Modular.get<AdminController>(tag: module.name);
    AdminController adminController = AdminController(module: module);
    return adminController.getCollectionReference();
  }

  showError(/*BuildContext context, */ e) {
    print(e);
    String message = "Error al guardar";
    if (e is FirebaseException) {
      print(e.code);
      if (e.code == "permission-denied") {
        message = "Error, no tiene permisos para realizar esta acción";
      }
    }
    Get.snackbar("Atehción", message,
        duration: Duration(seconds: 2), backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(20));
  }

  doGuardar(BuildContext context) async {
    Get.log("datos validos?");
    if (_formKey != null && _formKey!.currentState!.validate()) {
      Get.log("  si, válidos. Guardamos...");
      _formKey!.currentState?.save();

      // ñapa para guardar el documentref /values/null como nulo!!!
      for (var entry in this._updateData!.entries) {
        if (entry.value is DocumentReference) {
          DocumentReference tmp = entry.value;
          if (tmp.path == FieldTypeRef.nullValue.path) {
            _updateData![entry.key] = null;
          }
        }
      }

      bool isNew = object == null;

      String? msgValidation;

      if (module.validation != null) {
        msgValidation = await module.validation!(isNew, _updateData!);
      }

      bool doUpdate = true;
      if (module.onSave != null) {
        doUpdate = await module.onSave!(isNew, _updateData, object);
      }
      print("doUpdate $doUpdate. isNew = $isNew");
      //print(_updateData);
      if (msgValidation == null) {
        if (doUpdate) {
          if (!isNew) {
            // primero hacemos pop por si está offline que no se quede y permita pulsarlo muchas veces
            DashboardService.instance.pop();

            object!.reference.set(_updateData!, SetOptions(merge: true)).then((value) {
              if (module.onUpdated != null) module.onUpdated!(isNew, object!.reference);

              ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
                content: Text("Elemento guardado con éxito"),
                duration: Duration(seconds: 3),
              ));

              //Get.snackbar("Atención", "Elemento guardado con éxito", duration: Duration(seconds: 2), snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(20));
            }).catchError((e) {
              showError(e);
            });
          } else if (isNew) {
            // si en updateData hay un id, lo usamos
            String? id = _updateData!['id'] ?? null;
            Future? action;
            if (id != null) {
              action = _getCollection().doc(id).set(_updateData);
            } else {
              action = _getCollection().add(_updateData!);
            }
            // primero hacemos pop por si está offline que no se quede y permita pulsarlo muchas veces
            DashboardService.instance.pop();
            await action.then((value) {
              if (module.onUpdated != null) module.onUpdated!(isNew, value);
              ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
                content: Text("Elemento creado con éxito"),
                duration: Duration(seconds: 3),
              ));
            }).catchError((e) {
              showError(e);
            });
          }
        }
      } else {
        Get.snackbar("Atención", msgValidation, duration: Duration(seconds: 2));
      }
    } else {
      print("no se puede guardar, hay campos no validados");
    }
  }
}
