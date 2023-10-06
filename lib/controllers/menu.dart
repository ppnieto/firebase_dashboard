import 'package:firebase_dashboard/admin_modules.dart';
import 'package:get/get.dart';

class MenuController extends GetxController {
  MenuBase? _currentMenu;

  MenuBase? get currentMenu => _currentMenu;
  set currentMenu(MenuBase? mb) {
    _currentMenu = mb;
    update();
  }
}
