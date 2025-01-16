import 'dart:async';

import 'package:event_hub/event_hub.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v8.dart';

class EventController extends GetxController {
  static EventController get to => Get.find();

  final EventHub _eventHub = EventHub();
  Map<String, StreamSubscription> streamSubscriptions = {};

  String subscribe(String eventName, void Function(dynamic) call) {
    String uid = const Uuid().v8();
    streamSubscriptions[uid] = _eventHub.on(eventName, call);
    return uid;
  }

  void cancelSubscription(String uid) {
    streamSubscriptions[uid]?.cancel();
    streamSubscriptions.remove(uid);
  }

  void fire(String name, dynamic data) {
    Get.log('EventController::fire $name');
    _eventHub.fire(name, data);
  }
}

enum MbzEvents { onUserLogged, onUserLogout }

enum DashEvents { onDetalleUpdateData }
