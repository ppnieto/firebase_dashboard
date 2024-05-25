import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

class FieldTypeImageURL extends FieldType {
  final double width;
  final double height;
  bool allowUpload;
  bool allowURL;
  bool clickToOpen;
  String storePath;
  Widget? noImageWidget;
  bool showImageOnEdit;
  TextEditingController textController = TextEditingController();
  TextEditingController pathController = TextEditingController();

  FieldTypeImageURL(
      {required this.width,
      required this.height,
      this.allowURL = true,
      this.allowUpload = false,
      required this.storePath,
      this.showImageOnEdit = false,
      this.clickToOpen = false,
      this.noImageWidget});

  @override
  getListContent(
      BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      var value = _object.get(column.field);
      var url = value is Map
          ? _object[column.field]['url']
          : _object.get(column.field);
      Widget image = Image.network(
        url,
        width: this.width,
        height: this.height,
      );
      if (clickToOpen) {
        image = InkWell(
            child: image,
            onTap: () {
              launchUrl(Uri.parse(url));
            });
      }
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0), child: image);
    } else {
      return noImageWidget ??
          Text("<No hay imagen>", style: TextStyle(color: Colors.red));
    }
  }

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object,
      Map<String, dynamic> values, ColumnModule column) {
    var value = values[column.field];
    String url = "";

    if (value is Map) {
      url = value['url'];
      textController.text = url;
      pathController.text = value['path'] ?? "";
    } else {
      textController.text = "";
      pathController.text = "";
    }

    Widget image = url.isNotEmpty
        ? Image.network(url, height: 300)
        : const SizedBox.shrink();

    if (url.isNotEmpty && clickToOpen) {
      image = InkWell(
          child: image,
          onTap: () {
            launchUrl(Uri.parse(url));
          });
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
                  updateData(context, column,
                      {'url': val, 'path': pathController.text});
                })),
        if (showImageOnEdit) image,
        if (allowUpload) SizedBox(width: 20),
        if (allowUpload)
          IconButton(
            icon:
                Icon(Icons.upload_file, color: Theme.of(context).primaryColor),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _UploadDialog(
                      parent: this,
                      url: value.toString(),
                      column: column,
                    );
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
  final ColumnModule column;

  _UploadDialog(
      {Key? key, required this.parent, required this.url, required this.column})
      : super(key: key);

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

  void uploadFile() async {
    var res = await DashboardUtils.pickAndUploadFile(
        context, widget.parent.storePath);
    if (res != null) {
      String downloadUrl = await res.reference.getDownloadURL();
      setState(() {
        this.url = downloadUrl;
      });
      widget.parent.textController.text = downloadUrl;
      widget.parent.pathController.text = res.reference.fullPath;
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
      padding: EdgeInsets.all(50),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Subir imagen",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          SizedBox(height: 20),
          Expanded(
            child: Image.network(this.url),
          ),
          SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: () {
                    uploadFile();
                  },
                  child:
                      Text("Subir archivo...", style: TextStyle(fontSize: 18))),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Aceptar", style: TextStyle(fontSize: 18))),
                  SizedBox(width: 20),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancelar", style: TextStyle(fontSize: 18))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
