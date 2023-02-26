import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_dashboard/controllers/admin.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_dashboard/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetalleController extends GetxController {
  final DocumentSnapshot? object;
  final double labelWidth;
  final bool showLabel;
  final bool canDelete;
  final Module module;
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _updateData;
  StreamSubscription<DocumentSnapshot>? changesSubscription;

  DetalleController({this.object, required this.module, this.labelWidth = 120, this.showLabel = true, this.canDelete = true});

  @override
  void onInit() {
    super.onInit();

    _updateData = object?.data() as Map<String, dynamic>?;
    if (_updateData == null) {
      _updateData = {};
    }

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
    if (fieldName.contains('.')) {
      List<String> fields = fieldName.split('.');
      if (fields.length != 2) throw Exception("Error con sintaxis de campo $fieldName");
      if (_updateData!.containsKey(fields[0])) {
        _updateData![fields[0]][fields[1]] = value;
      } else {
        _updateData![fields[0]] = {fields[1]: value};
      }
    } else {
      _updateData![fieldName] = value;
    }
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
      } else {
        if (column.showLabelOnEdit && showLabel) {
          child = Row(children: [
            ConstrainedBox(constraints: BoxConstraints(minWidth: labelWidth), child: Text(column.label)),
            SizedBox(width: 20),
            Expanded(child: child)
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
          elevation: 5,
          color: Theme.of(context).canvasColor,
          margin: MediaQuery.of(context).size.width >= responsiveDashboardWidth ? EdgeInsets.all(20) : EdgeInsets.all(5),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width < responsiveDashboardWidth ? 32.0 : 5),
            child: Container(
                child: StreamBuilder(
                    stream: object?.reference.snapshots(),
                    builder: (context, snapshot) {
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
                                  }).toList())));
                    })),
          ),
        ),
      );

  CollectionReference _getCollection() {
    print("getCollection");
    // no usamos el AdminController por si es un detalle sin listado
    //AdminController adminController = Get.find<AdminController>(tag: module.name);
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

  doGuardar() async {
    print("datos validos?");
    if (_formKey.currentState!.validate()) {
      print("  si, válidos. Guardamos...");
      _formKey.currentState!.save();

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
        doUpdate = await module.onSave!(isNew, _updateData);
      }
      print("doUpdate $doUpdate. isNew = $isNew");
      print(_updateData);
      if (msgValidation == null) {
        if (doUpdate) {
          if (!isNew) {
            object!.reference.set(_updateData!, SetOptions(merge: true)).then((value) {
              if (module.onUpdated != null) module.onUpdated!(isNew, object!.reference);
              Get.nestedKey(DashboardMainScreen.dashboardKeyId)?.currentState?.pop();
              ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
                content: Text("Elemento guardado con éxito"),
                duration: Duration(seconds: 3),
              ));
              //Get.snackbar("Atención", "Elemento guardado con éxito", duration: Duration(seconds: 2), snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(20));
            }).catchError((e) {
              showError(e);
            });
          } else if (isNew) {
            print("guardamos datos nuevos");
            // si en updateData hay un id, lo usamos
            String? id = _updateData!['id'] ?? null;
            Future? action;
            if (id != null) {
              action = _getCollection().doc(id).set(_updateData);
            } else {
              action = _getCollection().add(_updateData!);
            }

            action.then((value) {
              if (module.onUpdated != null) module.onUpdated!(isNew, value);
              Get.nestedKey(DashboardMainScreen.dashboardKeyId)?.currentState?.pop();
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
