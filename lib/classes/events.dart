import 'package:firebase_dashboard/dashboard.dart';

class UserLogoutEvent {}

class UserLoggedEvent {
  final AppUser user;

  UserLoggedEvent({required this.user});
}

class DetalleUpdateEvent {
  final Map<String, dynamic> updateData;

  DetalleUpdateEvent({required this.updateData});
}
