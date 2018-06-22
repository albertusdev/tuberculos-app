import "package:flutter/material.dart";

import "package:firebase_auth/firebase_auth.dart";

import "package:tuberculos/routes.dart";

class LogoutScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            margin: new EdgeInsets.only(bottom: 16.0),
            child: new Text("Logging out...", style: Theme.of(context).textTheme.headline),
          ),
          new CircularProgressIndicator(),
        ],
      ),
    );
  }
}