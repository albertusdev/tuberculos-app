import "package:flutter/material.dart";

import "package:redux/redux.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:redux_thunk/redux_thunk.dart";

import "package:firebase_auth/firebase_auth.dart";

import "package:tuberculos/routes.dart";
import "package:tuberculos/utils.dart";
import "register_field.dart";
import "register_screen_redux.dart";

class RegisterScreen extends StatelessWidget {
  final Store<RegisterState> store = new Store<RegisterState>(
    registerReducer,
    initialState: new RegisterState(),
    middleware: [thunkMiddleware],
  );

  final int currentStep = 0;

  Widget getCurrentStepWidget() {
    return new StoreConnector<RegisterState, int>(
      converter: (store) => store.state.currentStep,
      builder: (context, currentStep) {
        Widget widget;
        int currentStep = store.state.currentStep;
        switch (currentStep) {
          case 1:
            widget = _FirstStepWidget();
            break;
          case 2:
            widget = _SecondStepWidget();
            break;
          case 3:
            widget = _ThirdStepWidget();
            break;
        }
        return widget;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = new WillPopScope(
      onWillPop: () {
        if (store.state.currentStep - 1 >= 1) {
          store.dispatch(RegisterActions.PrevPage);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: new Scaffold(
        body: getCurrentStepWidget(),
        bottomNavigationBar: new MaterialButton(
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
        ),
      ),
    );
    return new StoreProvider(
      store: store,
      child: child,
    );
  }
}

class _FirstStepWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _FirstStepWidgetState();
}

class _FirstStepWidgetState extends State<_FirstStepWidget> {

  final GlobalKey<FormState> _firstNameKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _lastNameKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _emailKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordKey = new GlobalKey<FormState>();

  bool isAnyFieldEmpty(RegisterState state) {
    return state.emailField.controller.text.isEmpty ||
        state.passwordField.controller.text.isEmpty ||
        state.firstNameField.controller.text.isEmpty ||
        state.lastNameField.controller.text.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder<RegisterState>(
      builder: (context, store) {
        return new Center(
          child: new Container(
            margin: new EdgeInsets.symmetric(horizontal: 50.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new TextFormField(
                  key: _firstNameKey,
                  controller: store.state.firstNameField.controller,
                  decoration: store.state.firstNameField.decoration,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "First Name can't be empty";
                    }
                  },
                ),
                new TextFormField(
                  key: _lastNameKey,
                  controller: store.state.lastNameField.controller,
                  decoration: store.state.lastNameField.decoration,
                ),
                new TextFormField(
                  key: _emailKey,
                  controller: store.state.emailField.controller,
                  decoration: store.state.emailField.decoration,
                ),
                new TextFormField(
                  key: _passwordKey,
                  controller: store.state.passwordField.controller,
                  decoration: store.state.passwordField.decoration,
                  obscureText: true,
                ),
                new Container(
                  margin: new EdgeInsets.only(top: 25.0),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new OutlineButton(
                          borderSide: new BorderSide(
                            color: Colors.blue,
                          ),
                          child: store.state.isLoading
                              ? new SizedBox(
                                  child: new CircularProgressIndicator(),
                                  height: 16.0,
                                  width: 16.0,
                                )
                              : new Text("Next"),
                          onPressed: () {
                            bool isValid = _firstNameKey.currentState.validate();
                            if (isValid) {
                              Scaffold.of(context).showSnackBar(
                                new SnackBar(content: new Text("Verified"))
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SecondStepWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text("Step 2"),
      ],
    ));
  }
}

class _ThirdStepWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}
