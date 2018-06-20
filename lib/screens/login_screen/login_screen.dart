import 'package:flutter/material.dart';

import "package:tuberculos/routes.dart";
import "login_form.dart";

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 50.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                "TuberculosApp",
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0),
              ),
              new LoginForm(),
            ],
          ),
        ),
      ),
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
