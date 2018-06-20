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
    _checkIsAuthenticated();
  }

  void _checkIsAuthenticated() async {
    String routeName = Routes.loginScreen.toString();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      try {
        var userInfo =
            await Firestore.instance.document("users/${user.email}").get();
        var isUserRoleExist = userInfo?.data?.containsKey("role") ?? false;
        if (isUserRoleExist) {
          var userRole = userInfo.data["role"];
          if (isApoteker(userRole)) {
            routeName = Routes.apotekerHomeScreen.toString();
          } else if (isPasien(userRole)) {
            routeName = Routes.pasienHomeScreen.toString();
          }
        }
      } catch (e) {
        Scaffold
            .of(context)
            .showSnackBar(new SnackBar(content: new Text(e.toString())));
      }
    }
    new Timer(new Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, routeName);
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
      bottomNavigationBar: new Container(
        margin: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 50.0),
        child: LinearProgressIndicator(),
      ),
    );
  }
}
