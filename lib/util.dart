import 'dart:typed_data';

//import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:download/download.dart' as d;
import 'package:sweetsheet/sweetsheet.dart';
import 'package:uuid/uuid.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';

class UploadResult {
  final Reference reference;
  final Uint8List content;

  UploadResult({required this.reference, required this.content});
}

class DashboardUtils {
  const DashboardUtils._();

  static Future<UploadResult> uploadFile(
      BuildContext context, String path, Uint8List content) async {
    loading(context, "Por favor espere");
    try {
      Reference ref = FirebaseStorage.instance.ref(path);
      UploadTask task = ref.putData(content);
      await task.whenComplete(() {
        print("upload complete");
      }).onError((error, stackTrace) {
        print("error");
        throw error!;
      });
      return UploadResult(reference: ref, content: content);
    } finally {
      Navigator.of(context).pop();
    }
  }

  static Future<UploadResult?> pickAndUploadImage(
      {required BuildContext context,
      required String path,
      Size? resize}) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png'],
      uniformTypeIdentifiers: <String>['public.image'],
    );
    final XFile? xfile =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (xfile != null) {
      Uint8List fileBytes = await xfile.readAsBytes();
      try {
        img.Image? image = img.decodeImage(fileBytes);
        image = img.bakeOrientation(image!);
        if (resize != null) {
          image = img.copyResize(image,
              width: resize.width.toInt(), height: resize.height.toInt());
        }

        fileBytes = Uint8List.fromList(img.encodePng(image));
        return uploadFile(context, path, fileBytes);
      } on Error catch (e) {
        print("error en resize");
      }
    }
  }

  static Future<UploadResult?> pickAndUploadFile(
      BuildContext context, String path) async {
    final XFile? xfile = await openFile();
    if (xfile != null) {
      Uint8List fileBytes = await xfile.readAsBytes();
      String fileName = DashboardUtils.generateUUID() + "_" + xfile.name;

      // Upload file
      return uploadFile(context, '$path/$fileName', fileBytes);
    }
    /*
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = DashboardUtils.generateUUID() + "_" + result.files.first.name;

      // Upload file
      if (fileBytes != null) {
        return uploadFile(context, '$path/$fileName', fileBytes);
      }
    }
    */
    return null;
  }

  static void download(String fileName, List<int> bytes) {
    final stream = Stream.fromIterable(bytes);
    d.download(stream, fileName);
  }

  static Future<void> loading(BuildContext context, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withAlpha(140),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text(message,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.0,
                        fontFamily: "AvenirBlack"))
              ],
            ),
          ),
        );
      },
    ); // bajamos la resolucion
  }

  static String generateUUID() {
    var uuid = new Uuid(
        //options: {'grng': UuidUtil.cryptoRNG}
        );
    return uuid.v4();
  }

  static void confirm(
      {required BuildContext context,
      required String textPos,
      String textNeg = "Cancelar",
      required Function onPos,
      Function? onNeg,
      CustomSheetColor? color,
      required String title,
      required String description,
      IconData iconData = Icons.delete}) {
    final SweetSheet _sweetSheet = SweetSheet();
    _sweetSheet.show(
      context: context,
      title: Text(title),
      description: Text(description),
      color: color ?? SweetSheetColor.DANGER,
      icon: iconData,
      positive: SweetSheetAction(
        onPressed: () {
          onPos();
        },
        title: textPos,
      ),
      negative: SweetSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          if (onNeg != null) onNeg();
          return;
        },
        title: textNeg,
      ),
    );
  }

  static Future<List<String>> fixUrls(List<String> urls) async {
    List<String> result = [];
    for (var url in urls) {
      // filtramos las propias de firebase
      if (url.contains('appspot.com')) {
        String newUrl =
            await FirebaseStorage.instance.refFromURL(url).getDownloadURL();
        result.add(newUrl);
      } else {
        result.add(url);
      }
    }
    return result;
  }

  static Future<String> getUrlFromStoragePath(String path) async {
    return FirebaseStorage.instance.ref(path).getDownloadURL();
  }
}

extension ActionSpacing on List<Widget> {
  List<Widget> spacing(double num) {
    List<Widget> result = [];
    for (var widget in this) {
      result.add(widget);
      result.add(SizedBox(width: num));
    }
    return result;
  }
}
