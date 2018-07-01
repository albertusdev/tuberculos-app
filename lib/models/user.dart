import "package:google_sign_in/google_sign_in.dart" as GoogleSignIn;
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';

class User {
  // Roles
  static final String APOTEKER = "apoteker";
  static final String PASIEN = "pasien";

  String email;
  String displayName;
  String photoUrl;
  String role;
  DateTime dateTimeCreated;

  User({this.email, this.displayName, this.photoUrl, this.role});

  User.fromGoogleSignInAccount(GoogleSignIn.GoogleSignInAccount account)
      : email = account.email,
        displayName = account.displayName,
        photoUrl = account.photoUrl;

  User.fromJson(Map<dynamic, dynamic> json)
      : email = json["email"],
        displayName = json["displayName"],
        photoUrl = json["photoUrl"],
        role = json["role"],
        dateTimeCreated = json["dateTimeCreated"]
      ;

  factory User.createSpecificUserFromJson(Map<String, dynamic> json) {
    if (json["role"] == User.APOTEKER) {
      return new Apoteker.fromJson(json);
    } else {
      return new Pasien.fromJson(json);
    }
  }


  Map<String, dynamic> toJson() => {
        "email": email,
        "displayName": displayName,
        "photoUrl": photoUrl,
        "role": role,
        "dateTimeCreated": dateTimeCreated,
      };
}
