import "package:flutter/material.dart";

import "package:redux/redux.dart";
import "package:flutter_redux/flutter_redux.dart";

import "package:tuberculos/utils.dart";

import "package:tuberculos/screens/register_screen/redux/register_screen_redux.dart";
import "choose_apoteker_dialog.dart";

class ThirdStepWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new ThirdStepWidgetState();
}

class ThirdStepWidgetState extends State<ThirdStepWidget> {
  GlobalKey<FormState> _pasienFormKey = new GlobalKey<FormState>();
  GlobalKey<FormState> _apotekerFormKey = new GlobalKey<FormState>();

  Widget getPasienForm(BuildContext context, Store<RegisterState> store) {
    Map<String, dynamic> fields = store.state.fields;
    RegisterFormField alamat = fields["alamat"];
    SimpleField apotekerUsername = fields["apotekerUsername"];
    return new Form(
      key: _pasienFormKey,
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
          new FlatButton(
            onPressed: () {
              showChooseApotekerDialog(context: context, store: store);
            },
            child: new Text(apotekerUsername.data ?? "Pilih Apoteker-mu"),
          ),
        ],
      ),
    );
  }

  Widget getApotekerForm(BuildContext context, Store<RegisterState> store) {
    Map<String, dynamic> fields = store.state.fields;
    RegisterFormField alamatApotek = fields["alamatApotek"];
    RegisterFormField namaApotek = fields["namaApotek"];
    return new Form(
      key: _apotekerFormKey,
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
        store.dispatch(new ActionChangeField("apotekerUsername", new SimpleField(value)));
      }
    });
  }

  void submit(BuildContext context, Store<RegisterState> store) async {
    bool isFormValid = true;
    if (store.state.fields["role"].data == UserRole.apoteker) {
      isFormValid =
          _apotekerFormKey.currentState.validate();
    } else {
      isFormValid =
          _pasienFormKey.currentState.validate();
    }
    if (!isFormValid) {
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("Masukan tidak valid.")));
      return;
    }
    await signUp(context, store);
  }

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(builder: (context, Store<RegisterState> store) {
      Widget forms;
      if (store.state.fields["role"].data == UserRole.apoteker) {
        forms = getApotekerForm(context, store);
      } else {
        forms = getPasienForm(context, store);
      }
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
