import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class EventController extends GetxController {
  static EventController get to => Get.find();

  EventBus get bus => _eventHub;

  final EventBus _eventHub = EventBus();
  Map<String, StreamSubscription> streamSubscriptions = {};

  StreamSubscription<T> subscribe<T>(void Function(T) call) {
    return _eventHub.on<T>().listen(call, onDone: () {});
  }

  void fire<T>(T event) {
    Get.log('EventController::fire $event');
    _eventHub.fire(event);
  }
}

enum MbzEvents { onUserLogged, onUserLogout }

enum DashEvents { onDetalleUpdateData }
