import "dart:async";

import "package:flutter/material.dart";
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/redux/configure_store.dart';
import "package:tuberculos/routes.dart";
import 'package:tuberculos/utils.dart';

class SplashScreen extends StatefulWidget {
  final Store<AppState> store;

  SplashScreen({Key key, this.store}) : super(key: key);

  @override
  _SplashScreenState createState() => new _SplashScreenState(store);
}

class _SplashScreenState extends State<SplashScreen> {
  final Store<AppState> store;

  _SplashScreenState(this.store);

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() async {
    Store<AppState> store = this.store ?? StoreProvider.of<AppState>(context);
    new Timer(new Duration(seconds: 1), () async {
      User currentUser = store.state.currentUser;
      if (currentUser != null) {
        Navigator.pushReplacement(context, getRouteBasedOnUser(currentUser: currentUser));
      } else {
        Navigator.pushReplacementNamed(context, Routes.loginScreen.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = new Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: new Container(
        alignment: Alignment.center,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Image.asset("assets/pictures/logo.png", width: 144.0),
            new Text(
              "TuberculosApp",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Libel Suit",
                fontSize: 40.0,
              ),
            ),
          ],
        ),
      ),
    );
    return child;
  }
}
