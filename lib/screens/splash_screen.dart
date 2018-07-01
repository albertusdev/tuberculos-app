import "dart:async";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:redux/redux.dart';
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/redux/configure_store.dart';
import "package:tuberculos/routes.dart";
import 'package:tuberculos/screens/utils.dart';

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
    new Timer(new Duration(seconds: 1), () async {
      FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
      User currentUser = store.state.currentUser;
      if (firebaseUser != null && currentUser != null) {
        Navigator.pushReplacement(context, getRouteBasedOnUser(currentUser: currentUser));
      } else {
        Navigator.pushReplacementNamed(context, Routes.loginScreen.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = new Scaffold(
      body: new Center(
        child: Text(
          "TuberculosApp",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32.0,
          ),
        ),
      ),
    );
    return child;
  }
}
