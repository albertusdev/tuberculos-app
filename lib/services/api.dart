import "dart:async";
import 'dart:convert';
import 'dart:io';

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_one_signal/flutter_one_signal.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:tuberculos/models/alarm.dart';
import 'package:tuberculos/models/majalah.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/utils.dart';
import "package:uuid/uuid.dart";

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

Future<FirebaseUser> signInFirebaseWithGoogleSignIn(
    GoogleSignIn googleSignIn) async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    user = await googleSignIn.signIn();
  }
  GoogleSignInAuthentication credentials = await user.authentication;
  await FirebaseAuth.instance.signInWithGoogle(
    idToken: credentials.idToken,
    accessToken: credentials.accessToken,
  );
  FlutterOneSignal.setEmail(user.email);
  FlutterOneSignal.setSubscription(true);
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
  DocumentReference ref =
      getUserDocumentReference(role: user.role, email: user.email);
  await ref.setData(user.toJson());
  if (user is Pasien) {
    await getNestedPasienDocumentReference(
            apotekerEmail: user.apoteker, pasienEmail: user.email)
        .setData(user.toJson());
  }
}

Future<void> updateUser(User user) async {
  DocumentReference ref =
      getUserDocumentReference(role: user.role, email: user.email);
  await ref.updateData(user.toJson());
  if (user is Pasien) {
    getNestedPasienDocumentReference(
            apotekerEmail: user.apoteker, pasienEmail: user.email)
        .updateData(user.toJson());
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

CollectionReference getObatCollectionReference() {
  return Firestore.instance.collection("obats");
}

Future<void> createNewObat(Obat obat) async {
  await getObatCollectionReference().add(obat.toJson());
}

CollectionReference getPasienAlarmsCollectionReference(Pasien pasien) {
  return Firestore.instance.collection("pasiens/${pasien.email}/alarms");
}

CollectionReference getPasienObatsCollectionReference(Pasien pasien) {
  return Firestore.instance.collection("pasiens/${pasien.email}/obats");
}

DocumentReference getPasienObatDocumentReference(Pasien pasien, Obat obat) {
  return Firestore.instance
      .document("pasiens/${pasien.email}/obats/${obat.id}");
}

// Return download url of the file
Future<String> uploadFile(File file) async {
  String fileName = new Uuid().v1();
  StorageReference ref = FirebaseStorage.instance
      .ref()
      .child('$fileName-${file.path.split("/").last}');
  StorageUploadTask uploadTask = ref.putFile(file);
  final completedTask = await uploadTask.future;
  return completedTask.downloadUrl.toString();
}

Future<void> insertAlarm(Alarm alarm) async {
  DocumentReference documentReference =
      await getPasienAlarmsCollectionReference(alarm.user).add(alarm.toJson());
  alarm.id = documentReference.documentID;
  final body = {
    "include_player_ids": [alarm.user.oneSignalPlayerId],
    "headings": {"en": "${alarm.obat.name}"},
    "contents": {
      "en":
          "${alarm.user.displayName}, sudah saatnya minum obat ${alarm.obat.name}"
    },
    "large_icon": alarm.obat.photoUrl,
    "send_after": OneSignalHttpClient.formatDate(alarm.dateTime),
    "data": {
      "type": "alarm",
      "alarmId": documentReference.documentID,
      "pasienId": alarm.user.email,
    },
  };
  dynamic response = await OneSignalHttpClient.post(body: body);
  response = json.decode(response.body);
  documentReference.updateData({"notificationId": response["id"]});
}

Future<void> createAlarms(
    {Pasien pasien,
    Obat obat,
    String message,
    List<DateTime> dateTimes}) async {
  List<Alarm> alarms = dateTimes
      .map((DateTime dateTime) => new Alarm(
          user: pasien, obat: obat, message: message, dateTime: dateTime))
      .toList();
  alarms.forEach((Alarm alarm) async {
    await insertAlarm(alarm);
  });
  DocumentReference obatDocumentReference =
      getPasienObatDocumentReference(pasien, obat);
  DocumentSnapshot obatDocumentSnapshot = await obatDocumentReference.get();
  if (obatDocumentSnapshot.exists) {
    await obatDocumentReference.updateData(
        {"quantity": obatDocumentSnapshot.data["quantity"] + dateTimes.length});
  } else {
    await obatDocumentReference
        .setData(obat.toJson()..addAll({"quantity": dateTimes.length}));
  }
}

CollectionReference getMajalahCollectionReference() {
  return Firestore.instance.collection("majalahs");
}

Future<DocumentReference> createMajalah({
  @required String title,
  @required String description,
  @required File file,
  @required User creator,
  DateTime dateTimeCreated,
}) async {
  if (dateTimeCreated == null) dateTimeCreated = new DateTime.now();
  String downloadUrl = await uploadFile(file);
  Majalah majalah = new Majalah(
    title: title,
    description: description,
    creator: creator,
    dateTimeCreated: new DateTime.now(),
    downloadUrl: downloadUrl,
  );
  return getMajalahCollectionReference().add(majalah.toJson());
}

DocumentReference getAlarmDocumentReference({String pasienId, String alarmId}) {
  return Firestore.instance.document("pasiens/$pasienId/alarms/$alarmId");
}

Future<Alarm> getAlarm({String pasienId, String alarmId}) async {
  DocumentSnapshot ds = await getAlarmDocumentReference(pasienId: pasienId, alarmId: alarmId).get();
  return new Alarm.fromJson(ds.data)..id = ds.documentID;
}