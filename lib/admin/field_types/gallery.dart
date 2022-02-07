import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/admin/admin_modules.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import "package:universal_html/html.dart" as html;
import 'package:dashboard/admin/field_types/field_type_base.dart';

class FieldTypeGallery extends FieldType {
  final bool addUrls;
  final String storePath;
  List<String> urls = [];

  FieldTypeGallery({required this.storePath, this.addUrls = false});

  @override
  getListContent(DocumentSnapshot _object, ColumnModule column) {
    List tmp = _object.getFieldAdm(column.field, []);

    return Text(tmp.length.toString() + " imágenes");
  }

  void addImageURL() async {
    TextEditingController _textFieldController = TextEditingController();

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Introduzca la URL de la imagen'),
                IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            ),
            content: Container(
              width: 500,
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    onChanged: (value) {},
                    controller: _textFieldController,
                    decoration: InputDecoration(hintText: "URL de la imagen"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_textFieldController.text.isNotEmpty) {
                          this.urls.add(_textFieldController.text);
                        }

                        Navigator.of(context).pop();
                      },
                      child: Text("Aceptar"))
                ],
              ),
            ),
          );
        });
  }

  @override
  getEditContent(DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column, Function onChange) {
    List tmp = values[column.field] ?? [];
    this.urls = [];
    for (var value in tmp) {
      this.urls.add(value.toString());
    }
    return _Gallery(
      parent: this,
      name: column.label,
      addImageURL: this.addImageURL,
      onChange: () {
        // removing duplicates
        onChange(this.urls.toSet().toList());
      },
    );
  }
}

class _Gallery extends StatefulWidget {
  final FieldTypeGallery parent;
  final String name;
  final Function addImageURL;
  final Function onChange;
  _Gallery({Key? key, required this.parent, required this.name, required this.addImageURL, required this.onChange}) : super(key: key);

  @override
  __GalleryState createState() => __GalleryState();
}

class __GalleryState extends State<_Gallery> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Card(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(widget.name),
              Row(
                children: [
                  if (widget.parent.addUrls)
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          await widget.addImageURL();
                          // recargamos imagenes
                          widget.onChange();
                          setState(() {});
                        }),
                  IconButton(
                      icon: Icon(Icons.file_upload),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _UploadDialog(parent: widget.parent, onChange: widget.onChange);
                            });
                      }),
                ],
              )
            ]),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: widget.parent.urls
                  .map(
                    (url) => ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            child: Image.network(
                              url,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              widget.parent.urls.remove(url);
                              widget.onChange();
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      )),
    );
  }
}

class _UploadDialog extends StatefulWidget {
  final FieldTypeGallery parent;
  final Function onChange;

  _UploadDialog({Key? key, required this.parent, required this.onChange}) : super(key: key);

  @override
  __UploadDialogState createState() => __UploadDialogState();
}

class __UploadDialogState extends State<_UploadDialog> {
  String url = "";

  @override
  initState() {
    super.initState();
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
          widget.parent.urls.add(downloadURL);
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
                        widget.parent.urls.add(this.url);
                        widget.onChange();
                        setState(() {});
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
