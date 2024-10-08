import 'dart:typed_data';

import 'package:download/download.dart' as d;
import 'package:file_selector/file_selector.dart';
import 'package:firebase_dashboard/controllers/dashboard.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:sweetsheet/sweetsheet.dart';
import 'package:uuid/uuid.dart';

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
      try {
        Navigator.of(context).pop();
      } catch (e) {
        print("error!!!! $e");
      }
    }
  }

  static Future<UploadResult?> pickAndUploadImage({required BuildContext context, required String path, Size? resize}) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png'],
      uniformTypeIdentifiers: <String>['public.image'],
    );
    final XFile? xfile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (xfile != null) {
      Uint8List fileBytes = await xfile.readAsBytes();
      try {
        img.Image? image = img.decodeImage(fileBytes);
        image = img.bakeOrientation(image!);
        if (resize != null) {
          image = img.copyResize(image, width: resize.width.toInt(), height: resize.height.toInt());
        }

        fileBytes = Uint8List.fromList(img.encodePng(image));
        return uploadFile(context, path, fileBytes);
      } on Error catch (e) {
        print("error en resize");
      }
    }
  }

  static Future<UploadResult?> pickAndUploadFile(BuildContext context, String path) async {
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
                Text(message, style: TextStyle(color: Colors.white, fontSize: 13.0, fontFamily: "AvenirBlack"))
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
      String textPos = "Si",
      String textNeg = "No",
      required Function onPos,
      Function? onNeg,
      CustomSheetColor? color,
      required String title,
      required String description,
      IconData iconData = Icons.warning}) {
    final SweetSheet _sweetSheet = SweetSheet();
    _sweetSheet.show(
      context: context,
      title: Text(title),
      description: Text(description),
      color: color ?? SweetSheetColor.DANGER,
      icon: iconData,
      positive: SweetSheetAction(
        onPressed: () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
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
        String newUrl = await FirebaseStorage.instance.refFromURL(url).getDownloadURL();
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

/*
  static T serviceLocator<T extends GetxController>(BuildContext context) {
    return Get.find<T>();
  }
  */

/*
  static T serviceLocator<T extends State>(BuildContext context) {
    T? result = context.findAncestorStateOfType<T>();
    if (result == null) {
      // buscamos en los controladores registrados
      print("serviceLocator => " + T.toString());
      if (DashboardService.instance.hasController(T)) {
        return (DashboardService.instance.controller(T) as T);
      }
      throw new Exception("No encuentro servicio " + T.toString());
    }
    return result;
  }
  */

  static void navigate({required String route, dynamic arguments}) {
    Get.toNamed(route, id: DashboardController.idNestedNavigation, arguments: arguments);
  }

  static void navigateTo({required Widget child, dynamic arguments}) {
    Get.to(() => child, id: DashboardController.idNestedNavigation, arguments: arguments);
  }

  static void navigateOffAll(String route) {
    Get.offAllNamed(route, id: DashboardController.idNestedNavigation);
  }

  static T? findController<T extends GetxController>({required BuildContext context, String? tag}) {
    GetBuilderState<T>? state = context.findRootAncestorStateOfType<GetBuilderState<T>>();
    Get.log('findController<${T}> => ${state?.controller}');
    if (state == null) {
      if (Get.isRegistered<T>()) {
        Get.log('   lo encuentro con Get.find');
        return Get.find<T>(tag: tag);
      }
      debugPrintStack();
    }
    return state?.controller;
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
