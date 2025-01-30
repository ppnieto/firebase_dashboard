import 'package:example/home.dart';
import 'package:example/listado1.dart';
import 'package:example/listado2.dart';
import 'package:example/listado3.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class Routes {
  static const INITIAL = '/';
  static const LISTADO_1 = '/listado1';
  static const LISTADO_2 = '/listado2';
  static const LISTADO_3 = '/listado3';

  static List<GetPage> pages = [
    GetPage(name: '/', page: () => HomeScreen(), children: [
      GetPage(name: '/', page: () => const SizedBox.shrink()),
      GetPage(name: '/listado1', page: () => Listado1Screen()),
      GetPage(name: '/listado2', page: () => Listado2Screen()),
      GetPage(name: '/listado3', page: () => Listado3Screen()),
    ])
  ];
}
