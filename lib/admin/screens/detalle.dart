import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/admin/admin_modules.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sweetsheet/sweetsheet.dart';

class DetalleScreen extends StatefulWidget {
  final Module module;
  final DocumentSnapshot? object;
  final double labelWidth;
  final CollectionReference? collection;

  DetalleScreen({Key? key, this.object, required this.module, this.labelWidth = 120, this.collection}) : super(key: key);

  @override
  State<DetalleScreen> createState() => DetalleScreenState();
}

class DetalleScreenState extends State<DetalleScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? updateData;

  StreamSubscription<DocumentSnapshot>? changesSubscription;

  @override
  initState() {
    super.initState();
    this.updateData = widget.object?.data() as Map<String, dynamic>?;
    if (this.updateData == null) {
      this.updateData = {};
    }

    changesSubscription = widget.object?.reference.snapshots().listen((value) {
      setState(() {
        this.updateData = value.data() as Map<String, dynamic>?;
      });
    });

    if (widget.module.onNew != null) {
      widget.module.onNew!(this.updateData);
    }
  }

  @override
  void dispose() {
    super.dispose();
    changesSubscription?.cancel();
  }

  getEditField(BuildContext context, ColumnModule column) {
    //print("getEditContent " + column.field);
    Widget? child = column.type.getEditContent(context, widget.object, updateData!, column);
    //print("getEditContent ok");

    if (child != null) {
      if (column.showLabelOnEdit) {
        child = Row(children: [
          ConstrainedBox(constraints: BoxConstraints(minWidth: widget.labelWidth), child: Text(column.label)),
          SizedBox(width: 20),
          Expanded(child: child)
        ]);
      }
      return Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.width < responsiveDashboardWidth ? 5 : 20), child: child);
    } else
      return SizedBox.shrink();
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
                    stream: widget.object?.reference.snapshots(),
                    builder: (context, snapshot) {
                      return Builder(
                          builder: (context) => Form(
                              key: _formKey,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: widget.module.columns.map<Widget>((column) {
                                    if ((widget.object == null && column.showOnNew) || (widget.object != null && column.showOnEdit)) {
                                      return getEditField(context, column);
                                    } else {
                                      return Container();
                                    }
                                  }).toList())));
                    })),
          ),
        ),
      );

  showError(BuildContext context, e) {
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

  CollectionReference _getCollection() {
    if (widget.module.getQueryCollection != null) {
      return widget.module.getQueryCollection!();
    } else {
      String collectionPath = widget.collection?.path ?? widget.module.collection ?? widget.collection?.path ?? "";
      return FirebaseFirestore.instance.collection(collectionPath);
    }
  }

  doGuardar(BuildContext context) async {
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

      bool isNew = widget.object == null;

      String? msgValidation;

      if (widget.module.validation != null) {
        msgValidation = await widget.module.validation!(isNew, this.updateData!);
      }

      bool doUpdate = true;
      if (widget.module.onSave != null) {
        doUpdate = await widget.module.onSave!(isNew, this.updateData);
      }
      print("doUpdate $doUpdate");
      if (msgValidation == null) {
        if (doUpdate) {
          if (!isNew) {
            widget.object!.reference.update(this.updateData!).then((value) {
              if (widget.module.onUpdated != null) widget.module.onUpdated!(isNew, widget.object!.reference);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Elemento guardado con éxito'),
                duration: Duration(seconds: 2),
              ));
              Navigator.of(context).pop();
            }).catchError((e) {
              showError(context, e);
            });
          } else if (isNew) {
            print("guardamos datos nuevos");
            print(this.updateData);
            // si en updateData hay un id, lo usamos
            String? id = updateData!['id'] ?? null;

            _getCollection().doc(id).set(this.updateData!).then((value) {
              if (widget.module.onUpdated != null) widget.module.onUpdated!(isNew, value);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Elemento guardado con éxito'),
                duration: Duration(seconds: 2),
              ));
              Navigator.of(context).pop();
            }).catchError((e) {
              showError(context, e);
            });
          }
        } else {
          /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Elemento guardado con éxito'),
            duration: Duration(seconds: 2),
          ));
          Navigator.of(context).pop();*/
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msgValidation),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.module.title + (widget.object == null ? " / nuevo" : " / detalle")),
            backgroundColor: DashboardMainScreen.dashboardTheme?.appBar2BackgroundColor ?? Theme.of(context).secondaryHeaderColor,
            centerTitle: false,
            actions: [
              IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(FontAwesomeIcons.save),
                onPressed: () {
                  doGuardar(context);
                },
              ),
              if (widget.module.canRemove)
                IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    doBorrar(context, widget.object!.reference, () {
                      Navigator.of(context).pop();
                    });
                  },
                )
            ],
          ),
          body: getDetail(context)),
    );
  }
}
