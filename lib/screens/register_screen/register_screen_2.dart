import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:redux/redux.dart";
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/redux/configure_store.dart';
import 'package:tuberculos/screens/utils.dart';
import "package:tuberculos/services/api.dart";
import "package:tuberculos/utils.dart";

class SecondStepWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SecondStepWidgetState();
}

class _SecondStepWidgetState extends State<SecondStepWidget> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  void _showChooseApotekerDialog(
      {BuildContext context, Store<AppState> store}) {
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

  void _submit(BuildContext context, Store<AppState> store) async {
    bool isFormValid = _formKey.currentState.validate();
    if (!isFormValid) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("Masukan tidak valid.")));
      return;
    }
    String role = store.state.registerState.role;
    String apotekerEmail =
        store.state.registerState.pasienFields["apoteker"].data;
    if (role == User.PASIEN && apotekerEmail == null) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("Apoteker tidak boleh kosong.")));
      return;
    }
    try {
      Map<String, dynamic> json = await signUp(store);
      while (Navigator.of(context).canPop()) Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(getRouteBasedOnUser(
          currentUser: new User.createSpecificUserFromJson(json)));
    } catch (e) {
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text(e.toString())));
    }
  }

  Widget _buildApotekerForm(BuildContext context, Store<AppState> store) {
    Map<String, RegisterField> fields =
        store.state.registerState.apotekerFields;
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

  Widget _buildPasienForm(BuildContext context, Store<AppState> store) {
    var fields = store.state.registerState.fields;
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
                        _showChooseApotekerDialog(
                            context: context, store: store);
                      },
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(apotekerUsername.data ??
                              "Pilih Email Apoteker-mu"),
                          new Icon(Icons.menu)
                        ],
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(builder: (context, Store<AppState> store) {
      Widget forms = store.state.registerState.role == UserRole.apoteker
          ? _buildApotekerForm(context, store)
          : _buildPasienForm(context, store);
      RegisterState state = store.state.registerState;
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
                        capitalize(state.role),
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
                          child: state.isLoading
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
                          color: Theme.of(context).primaryColorDark,
                          onPressed: !state.isLoading
                              ? () {
                                  _submit(context, store);
                                }
                              : null,
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
