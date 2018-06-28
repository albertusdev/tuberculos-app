import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:tuberculos/screens/splash_screen.dart";
import "package:tuberculos/screens/login_screen.dart";
import "package:tuberculos/screens/register_screen/register_screen.dart";
import "package:tuberculos/screens/pasien_screens/pasien_home_screen.dart";
import "package:tuberculos/screens/apoteker_screens/apoteker_home_screen.dart";

import "routes.dart";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "TuberculosApp",
      home:  SplashScreen(),
      theme: new ThemeData(
        primaryColor: Colors.green,
        accentColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      routes: <String, WidgetBuilder>{
        (Routes.loginScreen.toString()): (BuildContext context) =>
             LoginScreen(),
        Routes.splashScreen.toString(): (BuildContext context) =>
             SplashScreen(),
        Routes.registerScreen.toString(): (BuildContext context) =>
             RegisterScreen(),
      },
    );
  }
}

void main() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

