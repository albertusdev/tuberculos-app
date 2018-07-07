import "package:flutter/material.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:redux/redux.dart";
import "package:tuberculos/models/user.dart";
import 'package:tuberculos/redux/configure_store.dart';
import "package:tuberculos/services/api.dart";
import "package:tuberculos/widgets/continue_with_google_button.dart";

import "register_screen.dart";

class ChooseRoleWidget extends StatelessWidget {
  void _handleOnContinueWithGooglePressed(
      {BuildContext context, Store<AppState> store}) async {
    String role = store.state.registerState.role;
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
                builder: (context) => new RegisterScreen(currentStep: 2)),
          );
    } catch (e) {
      Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text(e.toString()),
          ));
    }
    store.dispatch(new ActionClearLoading());
  }

  Widget _buildWidget(BuildContext context, Store<AppState> store) {
    String role = store.state.registerState.role;
    User user = store.state.registerState.choosenUser;
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
            new Text("Daftar sebagai",
                style: new TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 20.0,
                )),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 32.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Flexible(
                    child: new IconButton(
                      icon: new Image.asset(
                        "assets/icons/pasien_button_${role == User.PASIEN ? "active" : "inactive"}.png",
                      ),
                      padding: new EdgeInsets.symmetric(vertical: 16.0),
                      onPressed: () => store.dispatch(new ActionSetRole(User.PASIEN)),
                      iconSize: role == User.PASIEN ? 72.0 : 64.0,
                    ),
                  ),
                  new Flexible(
                    child: new IconButton(
                      icon: new Image.asset(
                          "assets/icons/apoteker_button_${role == User.APOTEKER ? "active" : "inactive"}.png"),
                      iconSize: role == User.APOTEKER ? 72.0 : 64.0,
                      padding: new EdgeInsets.symmetric(vertical: 16.0),
                      onPressed: () => store.dispatch(new ActionSetRole(User.APOTEKER)),
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              margin: new EdgeInsets.only(top: 16.0),
              child: new ContinueWithGoogleButton(onPressed: () {
                _handleOnContinueWithGooglePressed(
                    context: context, store: store);
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
      builder: (context, Store<AppState> store) {
        return _buildWidget(context, store);
      },
    );
  }
}
