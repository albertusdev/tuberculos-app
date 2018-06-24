import "package:flutter/material.dart";

import "package:redux/redux.dart";
import "package:flutter_redux/flutter_redux.dart";
import 'package:tuberculos/routes.dart';

import "package:tuberculos/services/api.dart";
import "package:tuberculos/utils.dart";

import "package:tuberculos/screens/register_screen/redux/register_screen_redux.dart";
import "register_screen_2_1.dart";

class SecondStepWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SecondStepWidgetState();
}

class _SecondStepWidgetState extends State<SecondStepWidget> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Widget getPasienForm(BuildContext context, Store<RegisterState> store) {
    var fields = store.state.fields;
    RegisterFormField alamat = fields["alamat"];
    SimpleField apotekerUsername = fields["apoteker"];
    return new Form(
      key: _formKey,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new TextFormField(
            controller: alamat.controller,
            decoration: new InputDecoration(
              hintText: alamat.hint,
              errorText: alamat.error,
            ),
            validator: (val) =>
                val.isEmpty ? "Alamat tidak boleh kosong" : null,
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Container(
                  margin: new EdgeInsets.symmetric(vertical: 16.0),
                  child: new OutlineButton(
                    onPressed: () {
                      showChooseApotekerDialog(context: context, store: store);
                    },
                    child:
                        new Text(apotekerUsername.data ?? "Pilih Apoteker-mu"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getApotekerForm(BuildContext context, Store<RegisterState> store) {
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
              })
        ],
      ),
    );
  }

  void showChooseApotekerDialog(
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

  void submit(BuildContext context, Store<RegisterState> store) async {
    bool isFormValid = _formKey.currentState.validate();
    if (!isFormValid) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("Masukan tidak valid.")));
      return;
    }
    try {
      await signUp(store);
      String role = store.state.role;
      Routes redirectRoute = isApoteker(role)
          ? Routes.apotekerHomeScreen
          : Routes.pasienHomeScreen;
      while (Navigator.of(context).canPop()) Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(redirectRoute.toString());
    } catch (e) {
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(builder: (context, Store<RegisterState> store) {
      Widget forms = store.state.role == UserRole.apoteker
          ? getApotekerForm(context, store)
          : getPasienForm(context, store);
      return new Center(
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 50.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              forms,
              new Container(
                margin: const EdgeInsets.only(top: 16.0),
                child: new Row(
                  children: [
                    new Expanded(
                      child: new OutlineButton(
                        child: store.state.isLoading
                            ? new SizedBox(
                                width: 16.0,
                                height: 16.0,
                                child: new CircularProgressIndicator(),
                              )
                            : new Text("Sign Up"),
                        onPressed: () {
                          submit(context, store);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
