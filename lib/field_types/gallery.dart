import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_dashboard/components/image_storage.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/admin_modules.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FieldTypeGallery extends FieldType {
  final bool addUrls;
  bool canAdd;
  bool canRemove;
  String storePath;
  List<String> urls = [];

  FieldTypeGallery({this.storePath = "uploads", this.addUrls = false, this.canAdd = true, this.canRemove = true});

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    List tmp = _object.getFieldAdm(column.field, []);
    return Text("${tmp.length} imágenes");
  }

  void addImageURL(BuildContext context) async {
    TextEditingController textFieldController = TextEditingController();

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Introduzca la URL de la imagen'),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            ),
            content: SizedBox(
              width: 500,
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    onChanged: (value) {},
                    controller: textFieldController,
                    decoration: const InputDecoration(hintText: "URL de la imagen"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        if (textFieldController.text.isNotEmpty) {
                          urls.add(textFieldController.text);
                        }

                        Navigator.of(context).pop();
                      },
                      child: const Text("Aceptar"))
                ],
              ),
            ),
          );
        });
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    List tmp = values[column.field] ?? [];
    urls = [];
    for (var value in tmp) {
      if (value is String) {
        urls.add(value.toString());
      } else if (value is Map && value.containsKey('url')) {
        urls.add(value['url']!);
      }
    }
    return _Gallery(
      parent: this,
      name: column.label,
      addImageURL: addImageURL,
      onChange: () {
        // removing duplicates
        updateData(context, column, urls.toSet().toList());
      },
    );
/*
    return FutureBuilder(
        future: DashboardUtils.fixUrls(urls),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          urls = snapshot.data!;
          return _Gallery(
            parent: this,
            name: column.label,
            addImageURL: addImageURL,
            onChange: () {
              // removing duplicates
              updateData(context, column, urls.toSet().toList());
            },
          );
        });*/
  }
}

class _Gallery extends StatefulWidget {
  final FieldTypeGallery parent;
  final String name;
  final Function(BuildContext) addImageURL;
  final Function onChange;
  const _Gallery({Key? key, required this.parent, required this.name, required this.addImageURL, required this.onChange}) : super(key: key);

  @override
  __GalleryState createState() => __GalleryState();
}

class __GalleryState extends State<_Gallery> {
  void onRemove(String url) {
    // intentamos borrar la foto
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Card(
          child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.parent.addUrls
                      ? IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            await widget.addImageURL(context);
                            // recargamos imagenes
                            widget.onChange();
                            setState(() {});
                          })
                      : const SizedBox.shrink(),
                  if (widget.parent.canAdd)
                    IconButton(
                        icon: const Icon(Icons.file_upload),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            allowMultiple: true,
                          );
                          if (result != null) {
                            print(result.count);
                            for (var file in result.files) {
                              Uint8List? fileBytes = file.bytes;
                              String fileName = file.name;
                              // Upload file
                              if (fileBytes != null) {
                                UploadResult result = await DashboardUtils.uploadFile(context, '${widget.parent.storePath}/$fileName', fileBytes);

                                String url = await result.reference.getDownloadURL();
                                widget.parent.urls.add(url);
                                widget.onChange();
                              }
                            }
                          }
                          setState(() {});
                        }),
                ],
              )),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                //spacing: 20,
                //runSpacing: 20,
                children: widget.parent.urls.map((url) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        SizedBox(
                            width: 160,
                            height: 160,
                            child: ImageFromStorage(
                              url: url,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                            )),
                        if (widget.parent.canRemove)
                          Container(
                              color: Theme.of(context).primaryColor.withOpacity(0.6),
                              child: IconButton(
                                icon: Icon(Icons.delete, size: 20, color: Theme.of(context).colorScheme.secondary),
                                onPressed: () {
                                  DashboardUtils.confirm(
                                      context: context,
                                      description:
                                          "¿Desea borrar la foto seleccionada? Recuerde posteriormente guardar para que los cambios surjan efecto",
                                      textPos: "Si",
                                      textNeg: "No",
                                      title: "Atención",
                                      iconData: Icons.warning,
                                      onPos: () {
                                        onRemove(url);
                                        widget.parent.urls.remove(url);
                                        widget.onChange();
                                        Navigator.of(context).pop();
                                        setState(() {});
                                      });
                                },
                              )),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                                color: Theme.of(context).primaryColor.withOpacity(0.6),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.download,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  onPressed: () async {
                                    //launchUrlString(url);
                                    String newUrl = await firebase_storage.FirebaseStorage.instance.refFromURL(url).getDownloadURL();
                                    launchUrlString(newUrl);
                                  },
                                )))
                      ],
                    ),
                  ).paddingAll(10);
                }).toList(),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
/*
class _UploadDialog extends StatefulWidget {
  final FieldTypeGallery parent;
  final Function onChange;

  const _UploadDialog({Key? key, required this.parent, required this.onChange}) : super(key: key);

  @override
  __UploadDialogState createState() => __UploadDialogState();
}

class __UploadDialogState extends State<_UploadDialog> {
  String url = "";

  @override
  initState() {
    super.initState();
  }

  void uploadFile() async {
    UploadResult? result = await DashboardUtils.pickAndUploadFile(context, widget.parent.storePath);
    if (result != null) {
      String resultUrl = await result.reference.getDownloadURL();
      setState(() {
        url = resultUrl;
      });
    }
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
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [
        BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
      ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text("Subir imagen", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Expanded(
            child: url != "" ? Image.network(url) : const Placeholder(),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              TextButton(
                  onPressed: () {
                    uploadFile();
                  },
                  child: const Text("Subir archivo...", style: TextStyle(fontSize: 18))),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        widget.parent.urls.add(url);
                        widget.onChange();
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: const Text("Aceptar", style: TextStyle(fontSize: 18))),
                  const SizedBox(width: 20),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancelar", style: TextStyle(fontSize: 18))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/