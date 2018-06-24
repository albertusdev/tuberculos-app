import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:redux/redux.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:redux_thunk/redux_thunk.dart";

import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "package:tuberculos/routes.dart";

import "register_screen_1.dart";
import "register_screen_2.dart";

import "package:tuberculos/screens/register_screen/redux/register_screen_redux.dart";

class RegisterScreen extends StatelessWidget {
  static final Store<RegisterState> store = new Store<RegisterState>(
    registerReducer,
    initialState: new RegisterState(),
    middleware: [thunkMiddleware],
  );

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
      bottomNavigationBar: new StoreConnector<RegisterState, bool>(
        builder: (BuildContext context, bool isLoading) {
          List<Widget> children = <Widget>[
            new MaterialButton(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    "Already have an account? ",
                    style: new TextStyle(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  new Text(
                    " Log in.",
                    style: new TextStyle(
                      color: Theme.of(context).accentColor,
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
        converter: (Store<RegisterState> store) => store.state.isLoading,
      ),
    );
    return new StoreProvider(
      store: store,
      child: child,
    );
  }
}
