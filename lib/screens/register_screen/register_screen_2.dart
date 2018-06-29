import "package:flutter/material.dart";

import "package:redux/redux.dart";
import "package:flutter_redux/flutter_redux.dart";

import "package:cloud_firestore/cloud_firestore.dart";

import "package:tuberculos/screens/register_screen/redux/register_screen_redux.dart";
import "package:tuberculos/services/api.dart";
import "package:tuberculos/utils.dart";

import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/routes.dart';
import 'package:tuberculos/screens/apoteker_screens/apoteker_home_screen.dart';
import 'package:tuberculos/screens/pasien_screens/pasien_home_screen.dart';

class SecondStepWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SecondStepWidgetState();
}

class _SecondStepWidgetState extends State<SecondStepWidget> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  void _showChooseApotekerDialog(
      {BuildContext context, Store<RegisterState> store}) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => new ChooseApotekerDialog(),
    ).then<void>((String value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        store.dispatch(
            new ActionSetPasienField("apoteker", new SimpleField(value)));
      }
    });
  }

  void _submit(BuildContext context, Store<RegisterState> store) async {
    bool isFormValid = _formKey.currentState.validate();
    if (!isFormValid) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("Masukan tidak valid.")));
      return;
    }
    try {
      Map<String, dynamic> json = await signUp(store);
      print(json);
      Widget redirectedRouteWidget;
      String role = store.state.role;
      if (role == User.APOTEKER) {
        redirectedRouteWidget = new ApotekerHomeScreen(
          currentUser: new Apoteker.fromJson(json),
        );
      } else {
        redirectedRouteWidget = new PasienHomeScreen(
          currentUser: new Pasien.fromJson(json),
        );
      }
      while (Navigator.of(context).canPop()) Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (_) => redirectedRouteWidget));
    } catch (e) {
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text(e.toString())));
    }
  }

  Widget _buildApotekerForm(BuildContext context, Store<RegisterState> store) {
    Map<String, RegisterField> fields = store.state.apotekerFields;
    RegisterFormField alamatApotek = fields["alamatApotek"];
    RegisterFormField namaApotek = fields["namaApotek"];
    RegisterFormField sipa = fields["sipa"];
    return new Form(
      key: _formKey,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new TextFormField(
            controller: namaApotek.controller,
            decoration: new InputDecoration(
              hintText: namaApotek.hint,
              errorText: namaApotek.error,
            ),
            validator: (value) =>
                value.isEmpty ? "Nama Apotek tidak boleh kosong." : null,
          ),
          new TextFormField(
            controller: alamatApotek.controller,
            decoration: new InputDecoration(
              hintText: alamatApotek.hint,
              errorText: alamatApotek.error,
            ),
            validator: (value) =>
                value.isEmpty ? "Alamat Apotek tidak boleh kosong." : null,
          ),
          new TextFormField(
            controller: sipa.controller,
            decoration: new InputDecoration(
              hintText: sipa.hint,
              errorText: sipa.error,
            ),
            validator: (value) {
              if (value.isEmpty) return "SIPA tidak boleh kosong.";
              if (value.length < 12) return "SIPA kurang dari 12 digit.";
            },
            keyboardType: TextInputType.number,
            inputFormatters: [new SipaTextFormatter()],
          )
        ],
      ),
    );
  }

  Widget _buildPasienForm(BuildContext context, Store<RegisterState> store) {
    var fields = store.state.fields;
    SimpleField apotekerUsername = fields["apoteker"];
    return new Form(
      key: _formKey,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Container(
                  margin: new EdgeInsets.symmetric(vertical: 16.0),
                  child: new OutlineButton(
                    onPressed: () {
                      _showChooseApotekerDialog(context: context, store: store);
                    },
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(apotekerUsername.data ?? "Pilih Email Apoteker-mu"),
                        new Icon(Icons.menu)
                      ],
                    )
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Store<RegisterState> store) {
    Widget header;
    String role = store.state.role;
  }

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(builder: (context, Store<RegisterState> store) {
      Widget forms = store.state.role == UserRole.apoteker
          ? _buildApotekerForm(context, store)
          : _buildPasienForm(context, store);
      return new Container(
        margin: new EdgeInsets.fromLTRB(48.0, 32.0, 48.0, 0.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new SizedBox(
              height: 72.0,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Container(
                    decoration: new BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: new BorderRadius.vertical(
                          top: new Radius.circular(8.0),
                          bottom: new Radius.circular(8.0),
                        )),
                    padding: new EdgeInsets.only(left: 4.0),
                    margin: new EdgeInsets.only(right: 16.0),
                    child: new Text(""),
                  ),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Container(
                        child: new Text(
                          "Sebagai",
                          textAlign: TextAlign.start,
                          style: new TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 16.0,
                          ),
                        ),
                        margin: new EdgeInsets.only(top: 8.0),
                      ),
                      new Text(
                        capitalize(store.state.role),
                        textAlign: TextAlign.start,
                        style: new TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            new Expanded(
                child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                forms,
                new Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: new Row(
                    children: [
                      new Expanded(
                        child: new MaterialButton(
                          child: store.state.isLoading
                              ? new SizedBox(
                                  width: 16.0,
                                  height: 16.0,
                                  child: new CircularProgressIndicator(),
                                )
                              : new Text(
                                  "DAFTAR",
                                  style: new TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            _submit(context, store);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )),
          ],
        ),
      );
    });
  }
}

class ChooseApotekerDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ChooseApotekerDialogState();
}

class _ChooseApotekerDialogState extends State<ChooseApotekerDialog> {
  String query = "";
  bool isLoading = false;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      query = controller.text;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Widget _getCircleAvatarChild(document) {
    if (document["photoUrl"] == null) {
      if (document["displayName"] != null) {
        return new Text(document["displayName"]);
      } else {
        return new Text("...");
      }
    }
    return null;
  }

  Widget _buildStreams() {
    return new StreamBuilder<QuerySnapshot>(
        stream: apotekerReference.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          Widget child;
          if (!snapshot.hasData) {
            child = const Text('Loading...');
          }
          final data = snapshot.data.documents.where((documentSnapshot) {
            if (query.isEmpty)
              return true;
            else if (documentSnapshot.documentID.contains(query))
              return true;
            else if (documentSnapshot.data["displayName"].contains(query))
              return true;
            else
              return false;
          }).toList();
          final int dataCount = data.length;
          if (dataCount > 0) {
            child = new ListView.builder(
              itemCount: dataCount,
              itemBuilder: (_, int index) {
                final DocumentSnapshot document = data[index];
                return new ListTile(
                    leading: new CircleAvatar(
                      backgroundImage: document['photoUrl'] != null
                          ? new NetworkImage(document['photoUrl'])
                          : null,
                      child: _getCircleAvatarChild(document),
                    ),
                    subtitle:
                        new Text(document['email'] ?? '<No message retrieved>'),
                    title: new Text('${document["displayName"]}'),
                    onTap: () {
                      Navigator.pop(context, document["email"]);
                    });
              },
            );
          } else {
            child = new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                      "Maaf, belum ada Apoteker yang terdaftar dalam sistem."),
                ],
              ),
            );
          }
          return child;
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Dialog(
      child: _buildStreams(),
    );
  }
}
