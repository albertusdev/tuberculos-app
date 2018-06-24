import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:flutter_redux/flutter_redux.dart";

import "package:google_sign_in/google_sign_in.dart";

import "package:redux/redux.dart";

import "package:tuberculos/models/user.dart";
import "package:tuberculos/screens/register_screen/redux/register_screen_redux.dart";
import "package:tuberculos/services/api.dart";
import "package:tuberculos/widgets/continue_with_google_button.dart";
import "register_screen.dart";

class FirstStepWidget extends StatelessWidget {

  void _handleOnContinueWithGooglePressed(
      {BuildContext context, Store<RegisterState> store}) async {
    String role = store.state.role;
    GoogleSignIn googleSignIn = store.state.googleSignIn;
    GoogleSignInAccount user = googleSignIn.currentUser;
    try {
      await googleSignIn.signOut();
      user = await googleSignIn.signIn();
      if (user == null) throw "Mohon login dengan akun Google.";

      store.dispatch(new ActionSetLoading());

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

  Widget _buildWidget(BuildContext context, Store<RegisterState> store) {
    String role = store.state.role;
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
            new Text("Daftar sebagai", style: Theme.of(context).textTheme.headline),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Flexible(
                  child: new FlatButton(
                    child: new Column(
                      children: <Widget>[
                        new Icon(
                          Icons.accessibility,
                          color: role == User.pasien
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        new Text("Pasien",
                            style: new TextStyle(
                                color: role == User.pasien
                                    ? Theme.of(context).accentColor
                                    : null)),
                      ],
                    ),
                    padding: new EdgeInsets.symmetric(vertical: 16.0),
                    onPressed: () => store.dispatch(new ActionSetRole(User.pasien)),
                  ),
                ),
                new Flexible(
                  child: new FlatButton(
                    child: new Column(
                      children: <Widget>[
                        new Icon(
                          Icons.local_hospital,
                          color: role == User.apoteker
                              ? Theme.of(context).accentColor
                              : null,
                        ),
                        new Text(
                          "Apoteker",
                          style: new TextStyle(
                            color: role == User.apoteker
                                ? Theme.of(context).accentColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => store.dispatch(new ActionSetRole(User.apoteker)),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ],
            ),
            new Container(
              margin: new EdgeInsets.only(top: 16.0),
              child: new ContinueWithGoogleButton(onPressed: () {
                _handleOnContinueWithGooglePressed(context: context, store: store);
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(
      builder: (context, Store<RegisterState> store) {
        return _buildWidget(context, store);
      },
    );
  }
}
