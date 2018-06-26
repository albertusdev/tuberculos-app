import "package:google_sign_in/google_sign_in.dart" as GoogleSignIn;

class User {
  // Roles
  static final String APOTEKER = "apoteker";
  static final String PASIEN = "pasien";

  final String email;
  final String displayName;
  final String photoUrl;
  final String role;
  final DateTime dateTimeCreated;

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

  Map<String, dynamic> toJson() => {
        "email": email,
        "displayName": displayName,
        "photoUrl": photoUrl,
        "role": role,
        "dateTimeCreated": dateTimeCreated,
      };
}
