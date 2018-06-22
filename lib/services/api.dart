import "dart:async";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRole {
  static final String apoteker = "apoteker";
  static final String pasien = "pasien";
}

bool isPasien(String role) => role == UserRole.pasien;
bool isApoteker(String role) => role == UserRole.apoteker;

CollectionReference apotekerReference = Firestore.instance.collection("apotekers");

Future<bool> doesEmailExist(String email) async =>
    await hasRegisteredAsPasien(email) || await hasRegisteredAsApoteker(email);

Future<bool> hasRegisteredAsPasien(String email) async =>
    (await Firestore.instance.document("pasiens/$email").get())
        .exists;

Future<bool> hasRegisteredAsApoteker(String email) async =>
    (await Firestore.instance.document("apotekers/$email").get())
        .exists;

Future<bool> isUserDocumentExist({
  String email,
  String role,
}) async =>
    (await Firestore.instance.document("$role/$email").get()).exists;

Future<DocumentReference> createNewDocument(String collectionName, Map<String, dynamic> val) =>
    Firestore.instance.collection(collectionName).add(val);

Future<DocumentReference> createNewMessageDocument(Map<String, dynamic> val) =>
    createNewDocument("messages", val);

DocumentReference getUserDocumentReference({String role, String email}) =>
    Firestore.instance.document("${role}s/$email");

void signInFirebaseWithGoogleSignIn(GoogleSignIn googleSignIn) async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    user = await googleSignIn.signIn();
  }
  GoogleSignInAuthentication credentials = await user.authentication;
  await FirebaseAuth.instance.signInWithGoogle(
    idToken: credentials.idToken,
    accessToken: credentials.accessToken,
  );
}
