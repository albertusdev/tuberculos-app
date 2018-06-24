import "package:google_sign_in/google_sign_in.dart" as GoogleSignIn;

class User {

  // Roles
  static final String apoteker = "apoteker";
  static final String pasien = "pasien";

  final String email;
  final String displayName;
  final String photoUrl;

  User({this.email, this.displayName, this.photoUrl});

  User.fromGoogleSignInAccount(GoogleSignIn.GoogleSignInAccount account)
      : email = account.email,
        displayName = account.displayName,
        photoUrl = account.photoUrl;

  User.fromJson(Map<dynamic, dynamic> json) :
        email = json["email"],
        displayName = json["displayName"],
        photoUrl = json["photoUrl"];

  Map<String, dynamic> toJson() => {
    "email": email,
    "displayName": displayName,
    "photoUrl": photoUrl,
  };

}
