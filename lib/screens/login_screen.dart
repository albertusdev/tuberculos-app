import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import "package:google_sign_in/google_sign_in.dart";
import 'package:redux/redux.dart';
import "package:tuberculos/models/user.dart";
import 'package:tuberculos/redux/configure_store.dart';
import "package:tuberculos/routes.dart";
import "package:tuberculos/services/api.dart";
import 'package:tuberculos/utils.dart';
import "package:tuberculos/widgets/continue_with_google_button.dart";

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<StatefulWidget> {
  String role = User.PASIEN;
  bool isLoading = false;

  void _handleOnSignInButtonPressed(
      {BuildContext context, Store<AppState> store}) async {
    assert(role == User.APOTEKER || role == User.PASIEN);

    GoogleSignIn googleSignIn = store.state.googleSignIn;
    try {
      if (await googleSignIn.isSignedIn()) googleSignIn.signOut();
      GoogleSignInAccount googleSignInUser = await googleSignIn.signIn();
      if (googleSignInUser == null) throw "Mohon masuk menggunakan Akun Google";

      setState(() => isLoading = true);

      String email = googleSignInUser.email;

      if (!await doesEmailExist(email))
        throw "$email belum pernah terdaftar. Mohon daftar terlebih dahulu";

      if ((role == UserRole.apoteker &&
              !await hasRegisteredAsApoteker(email)) ||
          (role == UserRole.pasien && !await hasRegisteredAsPasien(email))) {
        throw "$email belum pernah terdaftar sebagai $role. Mohon daftar sebagai $role";
      }

      await signInFirebaseWithGoogleSignIn(googleSignIn);

      Map<String, dynamic> userJson =
          (await getUserDocumentSnapshot(role: role, email: email))?.data;

      User currentUser = new User.createSpecificUserFromJson(userJson)
        ..displayName = googleSignInUser.displayName
        ..photoUrl = googleSignInUser.photoUrl
        ..email = googleSignInUser.email;

      updateUser(currentUser);

      store.dispatch(new ActionChangeCurrentUser(currentUser: currentUser));

      setState(() => isLoading = false);

      while (Navigator.of(context).canPop()) Navigator.of(context).pop();
      Navigator
          .of(context)
          .pushReplacement(getRouteBasedOnUser(currentUser: currentUser));
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
    return new StoreBuilder(
      builder: (BuildContext context, Store<AppState> store) {
        return new Scaffold(
          body: new Builder(builder: (BuildContext context) {
            return new Center(
              child: new Container(
                margin: new EdgeInsets.symmetric(horizontal: 50.0),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      margin: new EdgeInsets.only(bottom: 64.0),
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            child: new Image.asset(
                                "assets/pictures/logo_black.png",
                                width: 144.0),
                            margin: new EdgeInsets.only(left: 8.0),
                          ),
                          new Text(
                            "TuberculosApp",
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                              fontFamily: "Libel Suit",
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Text(
                      "Masuk sebagai",
                      style: new TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 20.0,
                      ),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 32.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new Flexible(
                            child: new IconButton(
                              icon: new Image.asset(
                                  "assets/icons/pasien_button_${role == User.PASIEN ? "active" : "inactive"}.png",
                              ),
                              padding: new EdgeInsets.symmetric(vertical: 16.0),
                              onPressed: () => changeRole(User.PASIEN),
                              iconSize: role == User.PASIEN ? 72.0 : 64.0,
                            ),
                          ),
                          new Flexible(
                            child: new IconButton(
                              icon: new Image.asset(
                                  "assets/icons/apoteker_button_${role == User.APOTEKER ? "active" : "inactive"}.png"),
                              iconSize: role == User.APOTEKER ? 72.0 : 64.0,
                              padding: new EdgeInsets.symmetric(vertical: 16.0),
                              onPressed: () => changeRole(User.APOTEKER),
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Container(
                      margin: new EdgeInsets.only(top: 16.0),
                      child: new ContinueWithGoogleButton(onPressed: () {
                        _handleOnSignInButtonPressed(
                            context: context, store: store);
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
      },
    );
  }
}
