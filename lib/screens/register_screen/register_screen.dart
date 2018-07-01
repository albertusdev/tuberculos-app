import "package:flutter/material.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:redux/redux.dart";
import 'package:tuberculos/redux/configure_store.dart';
import "package:tuberculos/routes.dart";

import "register_screen_1.dart";
import "register_screen_2.dart";

class RegisterScreen extends StatelessWidget {
  final int currentStep;

  RegisterScreen({this.currentStep = 1});

  Widget getCurrentStepWidget() {
    Widget widget;
    switch (currentStep) {
      case 1:
        widget = new FirstStepWidget();
        break;
      case 2:
        widget = new SecondStepWidget();
        break;
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = new Scaffold(
      body: getCurrentStepWidget(),
      bottomNavigationBar: new StoreConnector<AppState, bool>(
        builder: (BuildContext context, bool isLoading) {
          List<Widget> children = <Widget>[
            new Divider(height: 8.0),
            new MaterialButton(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    margin: new EdgeInsets.only(right: 4.0),
                    child: new Text(
                      "Sudah punya akun?",
                      style: new TextStyle(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                  new Text(
                    "Masuk di sini.",
                    style: new TextStyle(
                      color: Theme.of(context).accentColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, Routes.loginScreen.toString());
              },
            )
          ];
          if (isLoading) children.add(new LinearProgressIndicator());
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
        },
        converter: (Store<AppState> store) => store.state.registerState.isLoading,
      ),
    );
    return child;
  }
}
