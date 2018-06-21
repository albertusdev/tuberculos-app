import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:redux/redux.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:redux_thunk/redux_thunk.dart";

import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "package:tuberculos/routes.dart";
import "package:tuberculos/utils.dart";
import "register_screen_redux.dart";

class RegisterScreen extends StatelessWidget {
  static final Store<RegisterState> store = new Store<RegisterState>(
    registerReducer,
    initialState: new RegisterState(),
    middleware: [thunkMiddleware],
  );

  final int currentStep;

  RegisterScreen({this.currentStep = 1});

  Widget getCurrentStepWidget() {
    Widget widget;
    switch (currentStep) {
      case 1:
        widget = new _FirstStepWidget();
        break;
      case 2:
        widget = new _SecondStepWidget();
        break;
      case 3:
        widget = new _ThirdStepWidget();
        break;
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = new Scaffold(
      body: getCurrentStepWidget(),
      bottomNavigationBar: new MaterialButton(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              "Already have an account? ",
              style: new TextStyle(
                color: Theme.of(context).disabledColor,
              ),
            ),
            new Text(
              " Log in.",
              style: new TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.pushReplacementNamed(
              context, Routes.loginScreen.toString());
        },
      ),
    );
    return new StoreProvider(
      store: store,
      child: child,
    );
  }
}

class _FirstStepWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _FirstStepWidgetState();
}

class _FirstStepWidgetState extends State<_FirstStepWidget> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return new StoreBuilder<RegisterState>(
      builder: (context, store) {
        RegisterState state = store.state;
        Map<String, dynamic> fields = state.fields;
        return new Center(
          child: new Container(
            margin: new EdgeInsets.symmetric(horizontal: 50.0),
            child: new Form(
              key: _formKey,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new TextFormField(
                    controller: fields["firstName"].controller,
                    decoration: fields["firstName"].decoration,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "First Name can't be empty";
                      }
                    },
                  ),
                  new TextFormField(
                    controller: fields["lastName"].controller,
                    decoration: fields["lastName"].decoration,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Last Name can't be empty";
                      }
                    },
                  ),
                  new TextFormField(
                    controller: fields["email"].controller,
                    decoration: fields["email"].decoration,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "E-mail can't be empty";
                      } else if (!isEmail(value)) {
                        return "This is not a valid e-mail format";
                      }
                    },
                    inputFormatters: <TextInputFormatter>[
                      new LowerCaseTextFormatter(),
                    ],
                  ),
                  new TextFormField(
                    controller: fields["password"].controller,
                    decoration: fields["password"].decoration,
                    obscureText: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Password can't be empty";
                      }
                    },
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 25.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new OutlineButton(
                            borderSide: new BorderSide(
                              color: Colors.blue,
                            ),
                            child: store.state.isLoading
                                ? new SizedBox(
                                    child: new CircularProgressIndicator(),
                                    height: 16.0,
                                    width: 16.0,
                                  )
                                : new Text("Next"),
                            onPressed: () async {
                              bool isValid = _formKey.currentState?.validate();
                              String content = "";
                              if (!isValid) {
                                content = "Input is not valid. Try again.";
                                Scaffold.of(context).showSnackBar(
                                    new SnackBar(content: new Text(content)));
                              } else {
                                try {
                                  bool emailHasNotExist =
                                      await verifyEmailHasNotExist(store);
                                  RegisterField current =
                                      fields["email"] as RegisterField;
                                  if (emailHasNotExist) {
                                    store.dispatch(new ActionNextPage());
                                    store.dispatch(new ActionChangeField(
                                        "email",
                                        new RegisterField(
                                          controller: current.controller,
                                          hint: current.hint,
                                          error: null,
                                        )));
                                    Navigator.of(context).push(
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                new RegisterScreen(
                                                    currentStep: 2)));
                                  } else {
                                    store.dispatch(new ActionChangeField(
                                        "email",
                                        new RegisterField(
                                          controller: current.controller,
                                          hint: current.hint,
                                          error:
                                              "User with that e-mail address has already exist.",
                                        )));
                                  }
                                } catch (e) {
                                  store.dispatch(new ActionClearLoading());
                                  Scaffold.of(context).showSnackBar(
                                        new SnackBar(
                                            content: new Text(e.toString())),
                                      );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SecondStepWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(
      builder: (context, Store<RegisterState> store) {
        return new Center(
            child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              "Choose your role",
              style: Theme.of(context).textTheme.headline,
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
                    onPressed: () {
                      store.dispatch(new ActionChooseRole(UserRole.pasien));
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
                  onPressed: () {
                    store.dispatch(new ActionChooseRole(UserRole.apoteker));
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

class _ThirdStepWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ThirdStepWidgetState();
}

class _ThirdStepWidgetState extends State<_ThirdStepWidget> {
  GlobalKey<FormState> _pasienFormKey = new GlobalKey<FormState>();
  GlobalKey<FormState> _apotekerFormKey = new GlobalKey<FormState>();

  Widget getPasienForm(BuildContext context, Store<RegisterState> store) {
    Map<String, dynamic> fields = store.state.fields;
    RegisterField alamat = fields["alamat"];
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
        ],
      ),
    );
  }

  Widget getApotekerForm(BuildContext context, Store<RegisterState> store) {
    Map<String, dynamic> fields = store.state.fields;
    RegisterField alamatApotek = fields["alamatApotek"];
    RegisterField namaApotek = fields["namaApotek"];
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
          )
        ],
      ),
    );
  }

  void signUp(BuildContext context, Store<RegisterState> store) async {
    bool isFormValid = true;
    if (store.state.fields["role"] == UserRole.apoteker) {
      isFormValid = _apotekerFormKey.currentState.validate();
    } else {
      isFormValid = _pasienFormKey.currentState.validate();
    }
    if (!isFormValid) {
      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Masukan tidak valid.")));
      return;
    }
    store.dispatch(new ActionSetLoading());
    try {
      Map<String, String> fields = store.state.fields.map(
          (key, value) => new MapEntry<String, String>(key, value.toString()));
      print(fields);
      String email = fields["email"];
      String password = fields["password"];
      fields.remove("password");
      FirebaseUser user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      DocumentReference ref = Firestore.instance.document("users/$email");
      Firestore.instance.runTransaction((Transaction tx) async {
        await tx.set(ref, fields);
      });
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      String role = fields["role"];
      String redirectRouteName = "";
      if (isApoteker(role)) {
        redirectRouteName = Routes.apotekerHomeScreen.toString();
      } else {
        redirectRouteName = Routes.pasienHomeScreen.toString();
      }
      while (Navigator.of(context).canPop()) Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(redirectRouteName);
    } catch (e) {
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text(e.toString())));
    }
    store.dispatch(new ActionClearLoading());
  }

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(builder: (context, Store<RegisterState> store) {
      Widget forms;
      if (store.state.fields["role"] == UserRole.apoteker) {
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
                          signUp(context, store);
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
