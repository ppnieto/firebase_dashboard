import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dashboard/classes/app_user.dart';
import 'package:firebase_dashboard/services/event.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find(); // add this line

  StreamSubscription<User?>? _authSubscription;

  final Future<AppUser> Function(String userId) appUserFactory;
  final Future<void> Function(AppUser? appUser) onUnserLogged;
  final List<AppUser> _userStack = [];

  AppUser? get appUser => _userStack.isNotEmpty ? _userStack.last : null;

  T getAppUser<T extends AppUser>() {
    return _userStack.last as T;
  }

  AuthService({required this.appUserFactory, required this.onUnserLogged});

  @override
  onInit() {
    super.onInit();
    _initializeAuthListener();
  }

  @override
  void onClose() {
    super.onClose();
    _authSubscription?.cancel();
  }

  Future<void> _initializeAuthListener() async {
    _authSubscription ??= FirebaseAuth.instance.userChanges().listen((User? user) async {
      Get.log('userChanges $user');
      if (user == null) {
        _userStack.clear();
        await onUnserLogged(null);
        Get.find<EventService>().hub.fire("auth/user/logout");
      } else {
        await signUser(user.uid);
      }
    });
  }

  Future<void> signUser(String userId) async {
    // comprobamos que no sea el último del stack
    if (_userStack.isEmpty || (_userStack.isNotEmpty && userId != _userStack.last.userDoc?.reference.id)) {
      Get.log('añadimos usuario a la pila ${_userStack.length}');
      _userStack.add(await appUserFactory(userId));
      await onUnserLogged(_userStack.last);
      Get.find<EventService>().hub.fire("auth/user/logged", userId);
    }
  }

  Future<void> signOut() async {
    Get.log('signOut ${_userStack.length}');
    if (_userStack.isNotEmpty) {
      Get.log('remove user from stack');
      _userStack.removeLast();
    }
    if (_userStack.isEmpty) {
      Get.log('FirebaseAuth.signOut');
      await FirebaseAuth.instance.signOut();
    } else {
      await onUnserLogged(_userStack.last);
    }
    Get.find<EventService>().hub.fire("auth/user/logout");
  }
}
