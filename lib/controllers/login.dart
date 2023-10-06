import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  bool _recordarCredenciales = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _loading = false;

  bool get loading => _loading;
  set loading(l) {
    _loading = l;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    GetStorage box = GetStorage();
    recordarCredenciales = box.read('recordarCredenciales') ?? false;

    String userName = "";
    String password = "";

    userName = box.read("userName") ?? "";
    password = box.read("password") ?? "";

    Get.log('userName = $userName');

    emailController.text = userName;
    passwordController.text = password;
  }

  void setPreferences() {
    GetStorage box = GetStorage();
    box.write('recordarCredenciales', recordarCredenciales);
    box.write('userName', emailController.text);
    box.write('password', passwordController.text);
    Get.log('write userName ' + emailController.text);
  }

  bool get recordarCredenciales => _recordarCredenciales;
  set recordarCredenciales(bool rc) {
    _recordarCredenciales = rc;
    update();
  }
}
