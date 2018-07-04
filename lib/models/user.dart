import "package:google_sign_in/google_sign_in.dart" as GoogleSignIn;
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';

class User {
  // Roles
  static final String APOTEKER = "apoteker";
  static final String PASIEN = "pasien";

  String uid;
  String email;
  String displayName;
  String photoUrl;
  String role;
  String oneSignalPlayerId;
  DateTime dateTimeCreated;

  User(
      {this.uid = "",
      this.email,
      this.displayName,
      this.photoUrl,
      this.role,
      this.oneSignalPlayerId});

  User.fromGoogleSignInAccount(GoogleSignIn.GoogleSignInAccount account)
      : email = account.email,
        displayName = account.displayName,
        photoUrl = account.photoUrl;

  User.fromJson(Map<dynamic, dynamic> json)
      : uid = json["uid"] ?? "",
        email = json["email"],
        displayName = json["displayName"],
        photoUrl = json["photoUrl"],
        role = json["role"],
        dateTimeCreated = json["dateTimeCreated"],
        oneSignalPlayerId = json["oneSignalPlayerId"];

  factory User.createSpecificUserFromJson(Map<String, dynamic> json) {
    if (json["role"] == User.APOTEKER) {
      return new Apoteker.fromJson(json);
    } else {
      return new Pasien.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "displayName": displayName,
        "photoUrl": photoUrl,
        "role": role,
        "dateTimeCreated": dateTimeCreated,
        "oneSignalPlayerId": oneSignalPlayerId,
      };

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is User) {
      return uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          role == other.role &&
          dateTimeCreated == other.dateTimeCreated &&
          oneSignalPlayerId == other.oneSignalPlayerId;
    }
    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode =>
      super.hashCode ^
      uid.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      role.hashCode ^
      dateTimeCreated.hashCode ^
      oneSignalPlayerId.hashCode;
}
