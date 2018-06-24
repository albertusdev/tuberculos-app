import "dart:async";
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:tuberculos/utils.dart";
import "package:tuberculos/routes.dart";

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() async {
    new Timer(new Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, Routes.loginScreen.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
  }
}
