import 'dart:html';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sweetsheet/sweetsheet.dart';

class GalleryScreen extends StatefulWidget {
  final String path;

  GalleryScreen(this.path);

  @override
  State<StatefulWidget> createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  firebase_storage.Reference destinosRef;

  @override
  void addFile() {
    Uint8List uploadedImage;
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        FileReader reader = FileReader();

        reader.onLoadEnd.listen((e) async {
          uploadedImage = reader.result;
          String fileName = widget.path + "/" + file.name;
          print("subimos " + fileName);
          firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref(fileName);
          firebase_storage.UploadTask uploadTask = ref.putData(uploadedImage);
          firebase_storage.TaskSnapshot task = await uploadTask;
          print("subido");
          setState(() {});
        });

        reader.onError.listen((fileEvent) {
          print("Some Error occured while reading the file");
        });

        reader.readAsArrayBuffer(file);
      }
    });
  }

  void deleteFile(firebase_storage.Reference file) async {
    final SweetSheet _sweetSheet = SweetSheet();
    _sweetSheet.show(
      context: context,
      title: Text("¿Está seguro de borrar el elemento?"),
      description: Text("Esta acción no podrá deshacerse después"),
      color: SweetSheetColor.DANGER,
      icon: Icons.delete,
      positive: SweetSheetAction(
        onPressed: () async {
          await file.delete();
          Navigator.of(context).pop();
          setState(() {});
        },
        title: 'Borrar',
      ),
      negative: SweetSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
        },
        title: 'Cancelar',
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

    destinosRef = storage.ref(widget.path);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Galería de fotos"), actions: [IconButton(icon: Icon(Icons.add), onPressed: addFile)]),
        body: FutureBuilder(
            future: destinosRef.listAll(),
            builder: (context, AsyncSnapshot<firebase_storage.ListResult> snapshot) {
              if (!snapshot.hasData) return Container();
              return GridView.count(
                  crossAxisCount: 5,
                  children: snapshot.data.items.map((item) {
                    return FutureBuilder(
                        future: item.getDownloadURL(),
                        builder: (context, AsyncSnapshot<String> urlSnapshot) {
                          if (!urlSnapshot.hasData) return Container();
                          return Stack(alignment: Alignment.bottomCenter, children: [
                            Container(width: double.infinity, height: double.infinity, child: Image.network(urlSnapshot.data, fit: BoxFit.cover)),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                  icon: Icon(FontAwesome.trash),
                                  color: Colors.white,
                                  onPressed: () {
                                    deleteFile(item);
                                  }),
                            ),
                            Container(
                                height: 50,
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.black.withAlpha(150)),
                                child: Text(
                                  item.fullPath,
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ))
                          ]);
                        });
                  }).toList());
            }));
  }
}
