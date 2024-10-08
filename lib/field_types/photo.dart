import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filesize/filesize.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class FieldTypePhoto extends FieldType {
  final String storePath;
  final Function? onUploadComplete;

  TextEditingController nameController = TextEditingController();
  TextEditingController sizeController = TextEditingController();

  Map<String, dynamic> data = {};

  FieldTypePhoto({required this.storePath, this.onUploadComplete});

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      var value = _object.get(column.field);
      if (value is Map) {
        if (value.containsKey('url')) {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: IconButton(
                  icon: Icon(Icons.file_copy, color: Theme.of(context).primaryColor),
                  onPressed: () {
                    launchUrl(Uri.parse(value['url'].toString()));
                  }));
        } else
          return SizedBox.shrink();
      } else if (value is String) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: IconButton(icon: Icon(Icons.file_copy, color: Theme.of(context).primaryColor), onPressed: () {}));
      } else {
        return Text("Error");
      }
    } else {
      return Text("<No hay imagen>", style: TextStyle(color: Colors.red));
    }
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    var value = values[column.field];
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
                enabled: false,
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
        SizedBox(width: 20),
        IconButton(
          icon: Icon(Icons.upload_file, color: Theme.of(context).primaryColor),
          onPressed: () async {
            ImageSource? imageSource = await Get.bottomSheet<ImageSource>(Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                      leading: Icon(Icons.photo),
                      onTap: () {
                        Get.back(result: ImageSource.gallery);
                      },
                      title: Text("Galería")),
                  ListTile(
                    leading: Icon(Icons.camera),
                    onTap: () {
                      Get.back(result: ImageSource.camera);
                    },
                    title: Text("Cámara"),
                  )
                ],
              ),
            ));
            if (imageSource != null) {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: imageSource);
              if (image != null) {
                UploadResult uploadResult = await DashboardUtils.uploadFile(context, storePath, await image.readAsBytes());
                firebase_storage.FullMetadata metadata = await uploadResult.reference.getMetadata();
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
                if (onUploadComplete != null) onUploadComplete!(uploadResult, data);
              }
            }
          },
        )
      ],
    );
  }
}
