import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:download/download.dart' as d;
import 'package:sweetsheet/sweetsheet.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class UploadResult {
  final Reference reference;
  final Uint8List content;

  UploadResult({required this.reference, required this.content});
}

class DashboardUtils {
  const DashboardUtils._();

  static Future<UploadResult> uploadFile(BuildContext context, String path, Uint8List content) async {
    loading(context, "Por favor espere");
    try {
      Reference ref = await FirebaseStorage.instance.ref(path);
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

  static Future<UploadResult?> pickAndUploadFile(BuildContext context, String path) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = result.files.first.name;

      // Upload file
      if (fileBytes != null) {
        return uploadFile(context, '$path/$fileName', fileBytes);
      }
    }
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
                Text(message, style: TextStyle(color: Colors.white, fontSize: 13.0, fontFamily: "AvenirBlack"))
              ],
            ),
          ),
        );
      },
    ); // bajamos la resolucion
  }

  static String generateUUID() {
    var uuid = new Uuid(options: {'grng': UuidUtil.cryptoRNG});
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
      String newUrl = await FirebaseStorage.instance.refFromURL(url).getDownloadURL();
      result.add(newUrl);
    }
    return result;
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
