import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dashboard/classes/app_user.dart';
import 'package:firebase_dashboard/classes/events.dart';
import 'package:firebase_dashboard/controllers/event.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find(); // add this line

  StreamSubscription<User?>? _authSubscription;

  final Future<AppUser> Function(String userId) appUserFactory;
  final Future<void> Function(AppUser? appUser) onUnserLogged;
  final List<AppUser> _userStack = [];

  AppUser? get appUser => _userStack.isNotEmpty ? _userStack.last : null;

  bool get hasUser => _userStack.isNotEmpty;

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
        EventController.to.fire(UserLogoutEvent());
      } else {
        await signUser(user.uid);
      }
    });
  }

  Future<void> signUser(String userId) async {
    // comprobamos que no sea el último del stack
    if (_userStack.isEmpty || (_userStack.isNotEmpty && userId != _userStack.last.userDoc?.reference.id)) {
      Get.log('añadimos usuario a la pila ${_userStack.length}');
      AppUser appUser = await appUserFactory(userId);
      _userStack.add(appUser);
      await onUnserLogged(_userStack.last);
      EventController.to.fire(UserLoggedEvent(user: appUser));
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
    EventController.to.fire(UserLogoutEvent());
  }
}
