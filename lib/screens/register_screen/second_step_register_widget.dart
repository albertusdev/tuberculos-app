import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:redux/redux.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:redux_thunk/redux_thunk.dart";

import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "package:tuberculos/routes.dart";
import "package:tuberculos/utils.dart";

import "register_screen.dart";
import "package:tuberculos/screens/register_screen/redux/register_screen_redux.dart";


class SecondStepWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(
      builder: (context, Store<RegisterState> store) {
        return new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.symmetric(vertical: 32.0),
                  child: new Text(
                    "Choose your role",
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new OutlineButton(
                        child: new Column(
                          children: <Widget>[
                            new Icon(Icons.accessibility),
                            new Text("Pasien"),
                          ],
                        ),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        padding: const EdgeInsets.all(16.0),
                        onPressed: () {
                          store.dispatch(new ActionChangeField("role", new SimpleField<UserRole>(UserRole.pasien)));
                          Navigator.of(context).push(
                            new MaterialPageRoute(
                                builder: (context) =>
                                new RegisterScreen(currentStep: 3)),
                          );
                        }),
                    new OutlineButton(
                      child: new Column(
                        children: <Widget>[
                          new Icon(Icons.local_hospital),
                          new Text("Apoteker"),
                        ],
                      ),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(75.0)),
                      padding: const EdgeInsets.all(16.0),
                      onPressed: () {
                        store.dispatch(new ActionChangeField("role", new SimpleField<UserRole>(UserRole.apoteker)));
                        Navigator.of(context).push(
                          new MaterialPageRoute(
                              builder: (context) =>
                              new RegisterScreen(currentStep: 3)),
                        );
                      },
                    )
                  ],
                )
              ],
            ));
      },
    );
  }
}
