import 'package:flutter/material.dart';
import 'package:tuberculos/models/pasien.dart';

import "package:tuberculos/routes.dart";

import "package:firebase_auth/firebase_auth.dart";

import "package:google_sign_in/google_sign_in.dart";
import 'package:tuberculos/screens/apoteker_screens/apoteker_home_screen.dart';
import 'package:tuberculos/screens/pasien_screens/pasien_home_screen.dart';

import "package:tuberculos/services/api.dart";
import "package:tuberculos/widgets/continue_with_google_button.dart";
import "package:tuberculos/models/user.dart";

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<StatefulWidget> {
  String role = User.PASIEN;
  bool isLoading = false;

  void _handleOnSignInButtonPressed({BuildContext context}) async {
    assert(role == User.APOTEKER || role == User.PASIEN);

    GoogleSignIn googleSignIn = new GoogleSignIn();
    try {
      if (await googleSignIn.isSignedIn()) googleSignIn.signOut();
      GoogleSignInAccount user = await googleSignIn.signIn();
      if (user == null) throw "Mohon masuk menggunakan Akun Google";

      setState(() => isLoading = true);

      String email = user.email;

      if (!await doesEmailExist(email))
        throw "$email belum pernah terdaftar. Mohon daftar terlebih dahulu";

      if ((role == UserRole.apoteker &&
              !await hasRegisteredAsApoteker(email)) ||
          (role == UserRole.pasien && !await hasRegisteredAsPasien(email))) {
        throw "$email belum pernah terdaftar sebagai $role. Mohon daftar sebagai $role";
      }

      await signInFirebaseWithGoogleSignIn(googleSignIn);

      Map<String, dynamic> userJson = (await getUserDocumentSnapshot(role: role, email: email))?.data;

      setState(() => isLoading = false);

      while (Navigator.of(context).canPop()) Navigator.of(context).pop();
      Widget newRoute;
      if (role == User.PASIEN) {
        Pasien pasien = new Pasien.fromJson(userJson);
        print('Current user chatId is ${pasien.chatId}');
        newRoute = new PasienHomeScreen(currentUser: pasien);
      } else {
        newRoute = new ApotekerHomeScreen();
      }
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
        builder: (BuildContext context) => newRoute
      ));
    } catch (e) {
      Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text(e.toString()),
          ));
      setState(() => isLoading = false);
    }
  }

  void changeRole(String role) {
    setState(() {
      this.role = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bottomNavigationBarChildren = [
      new Divider(height: 8.0),
      new MaterialButton(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.only(right: 4.0),
              child: new Text(
                "Belum punya akun?",
                style: new TextStyle(
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
            new Text(
              "Registrasi di sini.",
              style: new TextStyle(
                color: Theme.of(context).accentColor,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.pushNamed(context, Routes.registerScreen.toString());
        },
      )
    ];
    if (isLoading)
      bottomNavigationBarChildren.add(new LinearProgressIndicator());
    return new Scaffold(
      body: new Builder(builder: (BuildContext context) {
        return new Center(
          child: new Container(
            margin: new EdgeInsets.symmetric(horizontal: 50.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  margin: new EdgeInsets.all(16.0),
                  child: new Text(
                    "TuberculosApp",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 32.0),
                  ),
                ),
                new Text("Masuk sebagai", style: Theme.of(context).textTheme.headline),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new Flexible(
                      child: new FlatButton(
                        child: new Column(
                          children: <Widget>[
                            new Icon(
                              Icons.accessibility,
                              color: role == User.PASIEN
                                  ? Theme.of(context).accentColor
                                  : null,
                            ),
                            new Text("Pasien",
                                style: new TextStyle(
                                    color: role == User.PASIEN
                                        ? Theme.of(context).accentColor
                                        : null)),
                          ],
                        ),
                        padding: new EdgeInsets.symmetric(vertical: 16.0),
                        onPressed: () => changeRole(User.PASIEN),
                      ),
                    ),
                    new Flexible(
                      child: new FlatButton(
                        child: new Column(
                          children: <Widget>[
                            new Icon(
                              Icons.local_hospital,
                              color: role == User.APOTEKER
                                  ? Theme.of(context).accentColor
                                  : null,
                            ),
                            new Text(
                              "Apoteker",
                              style: new TextStyle(
                                color: role == User.APOTEKER
                                    ? Theme.of(context).accentColor
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () => changeRole(User.APOTEKER),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ],
                ),
                new Container(
                  margin: new EdgeInsets.only(top: 16.0),
                  child: new ContinueWithGoogleButton(onPressed: () {
                    _handleOnSignInButtonPressed(context: context);
                  }),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: new Column(
        mainAxisSize: MainAxisSize.min,
        children: bottomNavigationBarChildren,
      ),
    );
  }
}
