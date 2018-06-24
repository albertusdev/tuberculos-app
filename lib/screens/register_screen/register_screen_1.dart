import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_redux/flutter_redux.dart";

import "package:google_sign_in/google_sign_in.dart";

import "package:redux/redux.dart";
import "package:redux_thunk/redux_thunk.dart";

import "package:tuberculos/routes.dart";
import "package:tuberculos/screens/register_screen/redux/register_screen_redux.dart";
import "package:tuberculos/utils.dart";
import "package:tuberculos/services/api.dart";

import "register_screen.dart";

class FirstStepWidget extends StatelessWidget {
  void onUserRoleButtonPressed(
      {BuildContext context, Store<RegisterState> store, String role}) async {
    GoogleSignIn googleSignIn = store.state.googleSignIn;
    GoogleSignInAccount user = googleSignIn.currentUser;
    try {
      await googleSignIn.signOut();
      user = await googleSignIn.signIn();
      if (user == null) throw "Mohon login dengan akun Google.";

      String email = user.email;

      if (await doesEmailExist(email) &&
          ((role == UserRole.apoteker &&
                  await hasRegisteredAsApoteker(email)) ||
              (role == UserRole.pasien &&
                  await hasRegisteredAsPasien(email)))) {
        throw "$email sudah pernah terdaftar sebagai $role. Mohon memilih peran yang lain.";
      }
      store.dispatch(new ActionSetEmail(email));
      store.dispatch(new ActionSetRole(role));

      Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) =>
            new RegisterScreen(currentStep: 2)),
      );
    } catch (e) {
      Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text(e.toString()),
          ));
    }
    store.dispatch(new ActionClearLoading());
  }

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(
      builder: (context, Store<RegisterState> store) {
        return new Center(
            child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.symmetric(vertical: 32.0),
              child: new Text(
                "Choose your role",
                style: Theme.of(context).textTheme.headline,
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new OutlineButton(
                  child: new Column(
                    children: <Widget>[
                      new Icon(Icons.accessibility),
                      new Text("Pasien"),
                    ],
                  ),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  padding: const EdgeInsets.all(16.0),
                  onPressed: () => onUserRoleButtonPressed(
                      context: context, store: store, role: UserRole.pasien),
                ),
                new OutlineButton(
                  child: new Column(
                    children: <Widget>[
                      new Icon(Icons.local_hospital),
                      new Text("Apoteker"),
                    ],
                  ),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(75.0)),
                  padding: const EdgeInsets.all(16.0),
                  onPressed: () => onUserRoleButtonPressed(
                      context: context, store: store, role: UserRole.apoteker),
                )
              ],
            )
          ],
        ));
      },
    );
  }
}
