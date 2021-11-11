//import 'dart:html';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import "package:universal_html/html.dart" as html;
import 'package:dashboard/admin/field_types/field_type_base.dart';

class FieldTypeImageURL extends FieldType {
  final double width;
  final double height;
  bool allowUpload;
  String storePath;
  TextEditingController textController = TextEditingController();

  FieldTypeImageURL({required this.width, required this.height, this.allowUpload = false, required this.storePath});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Image.network(
          _object[column.field].toString(),
          width: this.width,
          height: this.height,
        ),
      );
    } else {
      return Text("<No hay imagen>", style: TextStyle(color: Colors.red));
    }
  }

  @override
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column, Function onChange) {
    var value = values[column.field];
    textController.text = value ?? "";
    return Row(
      children: [
        Expanded(
            child: TextFormField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: column.label,
                ),
                /*
                validator: (value) {
                  return onValidate != null ? onValidate(value) : null;
                },
                */
                onSaved: (val) {
                  if (onChange != null) onChange(val);
                })),
        allowUpload
            ? SizedBox(
                width: 20,
              )
            : SizedBox.shrink(),
        allowUpload
            ? IconButton(
                icon: Icon(Icons.upload_file),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _UploadDialog(parent: this, url: value.toString());
                      });
                },
              )
            : SizedBox.shrink()
      ],
    );
  }
}

class _UploadDialog extends StatefulWidget {
  final FieldTypeImageURL parent;
  final String url;

  _UploadDialog({Key? key, required this.parent, required this.url}) : super(key: key);

  @override
  __UploadDialogState createState() => __UploadDialogState();
}

class __UploadDialogState extends State<_UploadDialog> {
  late String url;

  @override
  initState() {
    super.initState();
    this.url = widget.url;
  }

  void uploadFile() {
    Uint8List? uploadedImage;
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files != null && files.length == 1) {
        final file = files[0];
        html.FileReader reader = html.FileReader();

        reader.onLoadEnd.listen((e) async {
          uploadedImage = reader.result as Uint8List?;
          String fileName = widget.parent.storePath + "/" + file.name;
          print("subimos " + fileName);
          firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref(fileName);
          firebase_storage.UploadTask uploadTask = ref.putData(uploadedImage!);
          firebase_storage.TaskSnapshot task = await uploadTask;
          print("subido");
          String downloadURL = await task.ref.getDownloadURL();
          print("url = " + downloadURL);
          widget.parent.textController.text = downloadURL;
          setState(() {
            this.url = downloadURL;
          });
        });

        reader.onError.listen((fileEvent) {
          print("Some Error occured while reading the file");
        });

        reader.readAsArrayBuffer(file);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      width: 800,
      height: 700,
      padding: EdgeInsets.all(50),
      decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
      ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Subir imagen",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Image.network(
              this.url,
            ),
          ),
          SizedBox(
            height: 22,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: () {
                    uploadFile();
                  },
                  child: Text(
                    "Subir archivo...",
                    style: TextStyle(fontSize: 18),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Aceptar",
                        style: TextStyle(fontSize: 18),
                      )),
                  SizedBox(width: 20),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancelar",
                        style: TextStyle(fontSize: 18),
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
