import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import "package:universal_html/html.dart" as html;

class FieldTypeImageURL extends FieldType {
  final double width;
  final double height;
  bool allowUpload;
  bool allowURL;
  String storePath;
  TextEditingController textController = TextEditingController();
  TextEditingController pathController = TextEditingController();

  FieldTypeImageURL({required this.width, required this.height, this.allowURL = true, this.allowUpload = false, required this.storePath});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      var value = _object.get(column.field);
      if (value is Map) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Image.network(
            _object[column.field]['url'],
            width: this.width,
            height: this.height,
          ),
        );
      } else
        return Text("Error");
    } else {
      return Text("<No hay imagen>", style: TextStyle(color: Colors.red));
    }
  }

  @override
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column, Function onChange) {
    var value = values[column.field];
    if (value is Map) {
      textController.text = value['url'] ?? "";
    }
    return Row(
      children: [
        Expanded(
            child: TextFormField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: column.label,
                ),
                enabled: this.allowURL,
                onSaved: (val) {
                  onChange({'url': val, 'path': pathController.text});
                })),
        //if (allowUpload) Expanded(child: TextFormField(controller: pathController)),
        if (allowUpload)
          SizedBox(
            width: 20,
          ),
        if (allowUpload)
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _UploadDialog(parent: this, url: value.toString());
                  });
            },
          )
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
          widget.parent.pathController.text = fileName;
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
