import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AppUser {
  DocumentSnapshot? userDoc;
  AppUser({this.userDoc});
}
