import 'package:flutter/material.dart';

import "package:tuberculos/routes.dart";

import "package:firebase_auth/firebase_auth.dart";

import "package:google_sign_in/google_sign_in.dart";

import "package:tuberculos/services/api.dart";

class LoginScreen extends StatelessWidget {
  void signIn({BuildContext context, String role}) async {
    assert(role == UserRole.apoteker || role == UserRole.pasien);

    GoogleSignIn googleSignIn = new GoogleSignIn();
    try {
      if (await googleSignIn.isSignedIn()) googleSignIn.signOut();
      GoogleSignInAccount user = await googleSignIn.signIn();
      if (user == null) throw "Mohon masuk menggunakan Akun Google";

      String email = user.email;

      if (!await doesEmailExist(email))
        throw "$email belum pernah terdaftar. Mohon daftar terlebih dahulu";

      if ((role == UserRole.apoteker &&
              !await hasRegisteredAsApoteker(email)) ||
          (role == UserRole.pasien && !await hasRegisteredAsPasien(email))) {
        throw "$email belum pernah terdaftar sebagai $role. Mohon daftar sebagai $role";
      }

      signInFirebaseWithGoogleSignIn(googleSignIn);
      while (Navigator.of(context).canPop()) Navigator.of(context).pop();
      Routes route = role == UserRole.apoteker
          ? Routes.apotekerHomeScreen
          : Routes.pasienHomeScreen;
      Navigator.of(context).pushReplacementNamed(route.toString());
    } catch (e) {
      Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text(e.toString()),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Builder(builder: (BuildContext context) {
        return new Center(
          child: new Container(
            margin: const EdgeInsets.symmetric(horizontal: 50.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  "TuberculosApp",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 32.0),
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new Flexible(
                      child: new OutlineButton(
                        child: new Column(
                          children: <Widget>[
                            new Icon(Icons.accessibility),
                            new Text("Pasien"),
                          ],
                        ),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        padding: const EdgeInsets.all(16.0),
                        onPressed: () =>
                            signIn(context: context, role: UserRole.pasien),
                      ),
                    ),
                    new Flexible(
                      child: new OutlineButton(
                        child: new Column(
                          children: <Widget>[
                            new Icon(Icons.local_hospital),
                            new Text("Apoteker"),
                          ],
                        ),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(75.0)),
                        padding: const EdgeInsets.all(16.0),
                        onPressed: () =>
                            signIn(context: context, role: UserRole.apoteker),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: new MaterialButton(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              "Don't have an account? ",
              style: new TextStyle(
                color: Theme.of(context).disabledColor,
              ),
            ),
            new Text(
              " Sign up.",
              style: new TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.pushNamed(context, Routes.registerScreen.toString());
        },
      ),
    );
  }
}
