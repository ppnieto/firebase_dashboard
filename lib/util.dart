import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

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
    /*
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    DateTime now = DateTime.now();
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    html.document.body!.children.add(anchor);
// download
    anchor.click();

// cleanup
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
    */
  }

  static void loading(BuildContext context, String message) async {
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
}
