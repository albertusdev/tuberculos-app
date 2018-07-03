import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/models/user.dart';

class UserRole {
  static final String apoteker = "apoteker";
  static final String pasien = "pasien";
}

bool isPasien(String role) => role == UserRole.pasien;
bool isApoteker(String role) => role == UserRole.apoteker;

CollectionReference apotekerReference =
    Firestore.instance.collection("apotekers");

Future<bool> doesEmailExist(String email) async =>
    await hasRegisteredAsPasien(email) || await hasRegisteredAsApoteker(email);

Future<bool> hasRegisteredAsPasien(String email) async =>
    (await Firestore.instance.document("pasiens/$email").get()).exists;

Future<bool> hasRegisteredAsApoteker(String email) async =>
    (await Firestore.instance.document("apotekers/$email").get()).exists;

Future<bool> isUserDocumentExist({
  String email,
  String role,
}) async =>
    (await Firestore.instance.document("$role/$email").get()).exists;

Future<DocumentReference> createNewDocument(
        String collectionName, Map<String, dynamic> val) =>
    Firestore.instance.collection(collectionName).add(val);

Future<DocumentReference> createNewMessageDocument(Map<String, dynamic> val) =>
    createNewDocument("chats", val);

DocumentReference getUserDocumentReference({String role, String email}) =>
    Firestore.instance.document("${role}s/$email");

Future<DocumentSnapshot> getUserDocumentSnapshot(
    {String role, String email}) async {
  return await (getUserDocumentReference(role: role, email: email)).get();
}

DocumentReference getMessageDocumentReference(String chatId) {
  return Firestore.instance.document("chats/$chatId");
}

CollectionReference getMessageCollectionReference(String chatId) {
  return Firestore.instance.collection("chats/$chatId/messages");
}

CollectionReference getPasiensCollectionReference(String apotekerEmail) {
  return Firestore.instance.collection("apotekers/$apotekerEmail/pasiens");
}


DocumentReference getNestedPasienDocumentReference(
    {String apotekerEmail, String pasienEmail}) {
  return Firestore.instance
      .document("apotekers/$apotekerEmail/pasiens/$pasienEmail");
}

Future<FirebaseUser> signInFirebaseWithGoogleSignIn(GoogleSignIn googleSignIn) async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    user = await googleSignIn.signIn();
  }
  GoogleSignInAuthentication credentials = await user.authentication;
  await FirebaseAuth.instance.signInWithGoogle(
    idToken: credentials.idToken,
    accessToken: credentials.accessToken,
  );
  return FirebaseAuth.instance.currentUser();
}

Future<void> updateProfileInFirestore(
    GoogleSignInAccount account, String role) async {
  assert(account != null);
  DocumentReference ref =
      getUserDocumentReference(role: role, email: account.email);
  ref.updateData({
    "email": account.email,
    "displayName": account.displayName,
    "photoUrl": account.photoUrl,
  });
}

Future<void> setUser(User user) async {
  DocumentReference ref = getUserDocumentReference(role: user.role, email: user.email);
  await ref.setData(user.toJson());
  if (user is Pasien) {
    await getNestedPasienDocumentReference(apotekerEmail: user.apoteker, pasienEmail: user.email).setData(user.toJson());
  }
}

Future<void> updateUser(User user) async {
  DocumentReference ref = getUserDocumentReference(role: user.role, email: user.email);
  await ref.updateData(user.toJson());
  if (user is Pasien) {
    getNestedPasienDocumentReference(apotekerEmail: user.apoteker, pasienEmail: user.email).updateData(user.toJson());
  }
}

Future<void> verifyPasien(String email, int tuberculosStage) async {
  DocumentReference ref =
      getUserDocumentReference(role: User.PASIEN, email: email);
  DocumentSnapshot snapshot = await ref.get();
  Pasien pasien = new Pasien.fromJson(snapshot.data);
  pasien.isVerified = true;
  pasien.tuberculosStage = tuberculosStage;
  await ref.updateData(pasien.toJson());
  DocumentReference duplicatedRef = getNestedPasienDocumentReference(
      apotekerEmail: pasien.apoteker, pasienEmail: pasien.email);
  await duplicatedRef.updateData(pasien.toJson());
}

