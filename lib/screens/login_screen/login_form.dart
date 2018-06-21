import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import "package:shared_preferences/shared_preferences.dart";

import "package:tuberculos/routes.dart";
import "package:tuberculos/utils.dart";
import "login_field_utils.dart";

class LoginForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isAnyFieldEmpty = true;
  LoginFieldUtils _emailFieldUtils;
  LoginFieldUtils _passwordFieldUtils;
  List<LoginFieldUtils> _fieldUtils;

  _LoginFormState() {
    _emailFieldUtils = new LoginFieldUtils(hintText: "E-mail");
    _passwordFieldUtils = new LoginFieldUtils(hintText: "Password");
    _fieldUtils = [_emailFieldUtils, _passwordFieldUtils];
    _emailFieldUtils.controller.addListener(_updateIsAnyFieldEmpty);
    _passwordFieldUtils.controller.addListener(_updateIsAnyFieldEmpty);
  }

  void _updateIsAnyFieldEmpty() {
    bool oldValue = _isAnyFieldEmpty;
    bool newValue = _fieldUtils.fold(
        false,
        (bool previousValue, LoginFieldUtils loginFieldUtils) =>
            previousValue || loginFieldUtils.controller.text.isEmpty);
    if (oldValue != newValue) {
      setState(() {
        _isAnyFieldEmpty = newValue;
      });
    }
  }

  void login() async {
    String email = _emailFieldUtils.controller.text;
    String password = _passwordFieldUtils.controller.text;
    FirebaseUser user;

    setState(() {
      _isLoading = true;
    });

    try {
      user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on PlatformException catch (e) {
      print(e.message);
      setState(() {
        _passwordFieldUtils.errorText = e.message;
      });
    } finally {
      if (user != null) {
        Navigator.pushReplacementNamed(
            context, Routes.pasienHomeScreen.toString());
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailFieldUtils.controller.dispose();
    _passwordFieldUtils.controller.dispose();
  }

  List<Widget> _buildTextFormFields() {
    return <Widget>[
      new TextFormField(
        controller: _emailFieldUtils.controller,
        decoration: InputDecoration(
          hintText: _emailFieldUtils.hintText,
        ),
        inputFormatters: <TextInputFormatter>[
          new LowerCaseTextFormatter(),
        ],
      ),
      new TextFormField(
        controller: _passwordFieldUtils.controller,
        decoration: InputDecoration(
          hintText: _passwordFieldUtils.hintText,
          errorText: _passwordFieldUtils.errorText,
          errorMaxLines: 2,
        ),
        obscureText: true,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.symmetric(vertical: 15.0),
          child: new Column(
            children: _buildTextFormFields(),
          ),
        ),
        new Row(
          children: <Widget>[
            new Expanded(
              child: new OutlineButton(
                borderSide: new BorderSide(
                  color: Theme.of(context).accentColor,
                ),
                child: _isLoading
                    ? new SizedBox(
                        child: new CircularProgressIndicator(),
                        height: 16.0,
                        width: 16.0,
                      )
                    : new Text("Sign-in"),
                disabledBorderColor: Theme.of(context).disabledColor,
                onPressed: _isAnyFieldEmpty ? null : login,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            )
          ],
        )
      ],
    );
  }
}
