import 'dart:async';
import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:http/http.dart" as http;
import "package:tuberculos/env.dart" as env;
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/screens/apoteker_screens/apoteker_home_screen.dart';
import 'package:tuberculos/screens/login_screen.dart';
import 'package:tuberculos/screens/pasien_screens/pasien_home_screen.dart';

var emailRegex =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

bool isEmail(String str) {
  RegExp regExp = new RegExp(emailRegex);
  return regExp.hasMatch(str);
}

bool isNumeric(String c) {
  assert(c.length == 1);
  return c.codeUnitAt(0) >= "0".codeUnitAt(0) && c.codeUnitAt(0) <= "9".codeUnitAt(0);
}

String capitalize(String s) {
  return s.substring(0, 1).toUpperCase() + s.substring(1);
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return new TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class SipaTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = "";
    for (int i = 0; i < newValue.text.length; ++i) {
      if (isNumeric(newValue.text[i])) {
        newText += newValue.text[i];
      }
    }
    String temp = newText;
    if (newText.length > 12) {
      temp = oldValue.text;
    }
    return new TextEditingValue(
      text: temp,
      selection: newValue.selection,
    );
  }
}

String getInitialsOfDisplayName(String displayName) {
  List<String> names = displayName.split(" ");
  if (names.length > 1) {
    names = [names[0], names.last];
  }
  print(names);
  return displayName.split(" ").fold(
      "", (String prev, String cur) => prev + (cur.length > 0 ? cur[0] : ""));
}


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


class OneSignalHttpClient {
  static final String oneSignalRestApiKey = env.ONE_SIGNAL_REST_API_KEY;
  static final String oneSignalAppId = env.ONE_SIGNAL_APP_ID;

  static final String oneSignalUrl = "https://onesignal.com/api/v1/notifications";

  static Future<http.Response> post({Map<String, String> headers, Map<String, dynamic> body}) {
    if (headers == null) headers = new Map<String, String>();
    headers["Content-Type"] = "application/json";
    headers["Authorization"] = "Basic $oneSignalRestApiKey";
    body["app_id"] = oneSignalAppId;
    return http.post(oneSignalUrl, headers: headers, body: json.encode(body));
  }
}
