import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "register_screen.dart";

import "package:redux/redux.dart";
import "package:flutter_redux/flutter_redux.dart";

import "package:tuberculos/utils.dart";

import "package:tuberculos/screens/register_screen/redux/register_screen_redux.dart";

import "register_screen.dart";
import "package:tuberculos/screens/register_screen/redux/register_screen_redux.dart";

class FirstStepWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new FirstStepWidgetState();
}

class FirstStepWidgetState extends State<FirstStepWidget> {
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
                        return "First Name tidak boleh kosong";
                      }
                    },
                  ),
                  new TextFormField(
                    controller: fields["lastName"].controller,
                    decoration: fields["lastName"].decoration,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Last Name tidak boleh kosong";
                      }
                    },
                  ),
                  new TextFormField(
                    controller: fields["email"].controller,
                    decoration: fields["email"].decoration,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "E-mail tidak boleh kosong";
                      } else if (!isEmail(value)) {
                        return "E-mail format tidak valid.";
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
                        return "Password tidak boleh kosong";
                      }
                      if (value.length < 6) {
                        return "Password setidaknya harus terdiri dari 6 digit.";
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
                                  RegisterFormField current =
                                  fields["email"] as RegisterFormField;
                                  if (emailHasNotExist) {
                                    store.dispatch(new ActionNextPage());
                                    store.dispatch(new ActionChangeField(
                                        "email",
                                        new RegisterFormField(
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
                                        new RegisterFormField(
                                          controller: current.controller,
                                          hint: current.hint,
                                          error:
                                          "User dengan alamat e-mail tersebut sudah ada.",
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
