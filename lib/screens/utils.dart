import "package:flutter/material.dart";
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/screens/apoteker_screens/apoteker_home_screen.dart';
import 'package:tuberculos/screens/login_screen.dart';
import 'package:tuberculos/screens/pasien_screens/pasien_home_screen.dart';

Route getRouteBasedOnUser({User currentUser}) {
  assert(currentUser.role != null);
  Widget widget;
  if (currentUser is Apoteker) {
    widget = new ApotekerHomeScreen(currentUser: currentUser,);
  } else if (currentUser is Pasien) {
    widget = new PasienHomeScreen(currentUser: currentUser,);
  } else {
    widget = new LoginScreen();
  }
  return new MaterialPageRoute(builder: (_) => widget);
}
