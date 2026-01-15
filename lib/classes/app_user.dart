import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AppUser {
  DocumentSnapshot userDoc;
  AppUser({required this.userDoc});
}
