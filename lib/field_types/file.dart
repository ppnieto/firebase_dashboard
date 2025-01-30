import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:url_launcher/url_launcher.dart';

class FieldTypeFile extends FieldType {
  final String storePath;
  final bool allowURL;
  final bool allowUpload;
  final Function? onUploadComplete;
  TextEditingController nameController = TextEditingController();
  TextEditingController sizeController = TextEditingController();

  Map<String, dynamic> data = {};

  FieldTypeFile(
      {required this.storePath,
      this.allowURL = false,
      this.allowUpload = true,
      this.onUploadComplete});

  @override
  getListContent(
      BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      var value = _object.get(column.field);
      if (value is Map) {
        if (value.containsKey('url')) {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: IconButton(
                  icon: Icon(Icons.file_copy,
                      color: Theme.of(context).primaryColor),
                  onPressed: () {
                    launchUrl(Uri.parse(value['url'].toString()));
                  }));
        } else
          return SizedBox.shrink();
      } else if (value is String) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: IconButton(
                icon: Icon(Icons.file_copy,
                    color: Theme.of(context).primaryColor),
                onPressed: () {}));
      } else {
        return Text("Error");
      }
    } else {
      return Text("<No hay imagen>", style: TextStyle(color: Colors.red));
    }
  }

  @override
  getEditContent(BuildContext context, ColumnModule column) {
    var value = getFieldValue(column);
    if (value is Map<String, dynamic>) {
      nameController.text = value['name'] ?? "";
      if (value.containsKey('size')) {
        sizeController.text = filesize(value['size']);
      }
      data = value;
    }
    return Row(
      children: [
        Flexible(
            flex: 2,
            child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: column.label,
                ),
                enabled: this.allowURL,
                onSaved: (val) {
                  updateData(context, column, data);
                })),
        SizedBox(width: 20),
        Flexible(
          flex: 1,
          child: TextFormField(
            controller: sizeController,
            enabled: false,
            decoration: InputDecoration(labelText: "Tamaño"),
          ),
        ),
        if (allowUpload) SizedBox(width: 20),
        if (allowUpload)
          IconButton(
            icon:
                Icon(Icons.upload_file, color: Theme.of(context).primaryColor),
            onPressed: () async {
              UploadResult? uploadResult =
                  await DashboardUtils.pickAndUploadFile(context, storePath);
              if (uploadResult != null) {
                firebase_storage.FullMetadata metadata =
                    await uploadResult.reference.getMetadata();
                String url = await uploadResult.reference.getDownloadURL();
                data = {
                  'path': uploadResult.reference.fullPath,
                  'size': metadata.size,
                  'name': uploadResult.reference.name,
                  'content-type': metadata.contentType,
                  'url': url
                };
                sizeController.text = filesize(metadata.size);
                nameController.text = uploadResult.reference.name;
                if (onUploadComplete != null)
                  onUploadComplete!(uploadResult, data);
              }
            },
          )
      ],
    );
  }
}
