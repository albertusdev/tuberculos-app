import 'dart:async';

import 'package:flutter/material.dart';

import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "package:redux/redux.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "package:tuberculos/utils.dart";
import "package:tuberculos/routes.dart";

abstract class RegisterField<T>  {
  T get data;
}

class SimpleField<T> implements RegisterField<T> {
  T data;
  SimpleField(this.data);
}

class RegisterFormField implements RegisterField<String> {
  TextEditingController controller;
  String hint;
  String error;

  RegisterFormField({
    TextEditingController controller,
    String hint,
    String error,
  }) {
    this.hint = hint ?? "";
    this.error = error;
    this.controller = controller ?? new TextEditingController();
  }

  @override
  int get hashCode => controller.hashCode ^ error.hashCode ^ hint.hashCode;

  @override
  bool operator ==(other) {
    return identical(this, other) ||
        (this.hint == other.hint &&
            this.error == other.error &&
            this.controller == other.controller);
  }

  InputDecoration get decoration => new InputDecoration(hintText: hint, errorText: error);

  @override
  String get data => controller?.text;
}

class ActionNextPage {}

class ActionPrevPage {}

class ActionSetLoading {}

class ActionClearLoading {}

class ActionChangeField {
  String key;
  RegisterField value;
  ActionChangeField(this.key, this.value);
}

class ActionCleanFields {}

class RegisterState {
  static final int maxStep = 3;

  int currentStep;
  bool isLoading;
  Map<String, dynamic> fields;

  RegisterState(
      {int currentStep, bool isLoading, Map<String, dynamic> fields}) {
    this.currentStep = currentStep ?? 1;
    this.isLoading = isLoading ?? false;
    this.fields = fields ??
        {
          "email": new RegisterFormField(hint: "E-mail"),
          "password": new RegisterFormField(hint: "Password"),
          "firstName": new RegisterFormField(hint: "First Name"),
          "lastName": new RegisterFormField(hint: "Last Name"),
          "role": new SimpleField<UserRole>(UserRole.pasien),
          "apotekerUsername": new SimpleField<String>(null),
          "sipa": new RegisterFormField(hint: "No. SIPA"),
          "alamat": new RegisterFormField(hint: "Alamat"),
          "namaApotek": new RegisterFormField(hint: "Nama Apotek"),
          "alamatApotek": new RegisterFormField(hint: "Alamat Apotek"),
          "pasien": new SimpleField<List<String>>(<String>[]),
        };
  }

  RegisterState clone({
    int currentStep,
    bool isLoading,
    Map<String, dynamic> fields,
  }) {
    return new RegisterState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      fields: fields ?? new Map.from(this.fields),
    );
  }
}

RegisterState registerReducer(RegisterState state, action) {
  RegisterState newState = state;
  if (action is ActionNextPage) {
    if (state.currentStep + 1 <= RegisterState.maxStep) {
      newState = state.clone(currentStep: state.currentStep + 1);
    }
  } else if (action is ActionPrevPage) {
    if (state.currentStep - 1 >= 1) {
      newState = state.clone(currentStep: state.currentStep - 1);
    }
  } else if (action is ActionSetLoading) {
    newState = state.clone(isLoading: true);
  } else if (action is ActionClearLoading) {
    newState = state.clone(isLoading: false);
  } else if (action is ActionChangeField) {
    Map<String, dynamic> fields = new Map.from(state.fields);
    fields[action.key] = action.value;
    newState = state.clone(fields: fields);
  } else if (action is ActionCleanFields) {
    state.fields.forEach((_, val) {
      if (val is RegisterFormField) {
        val.controller.dispose();
      }
    });
    newState = new RegisterState();
  } else {
    newState = state.clone();
  }
  return newState;
}

/// Return true if there is no error
/// Return false if there is error (network error or e-mail has already exist)
Future<bool> verifyEmailHasNotExist(Store<RegisterState> store) async {
  store.dispatch(new ActionSetLoading());
  String email = store.state.fields["email"].controller.text;
  DocumentSnapshot documentSnapshot =
      await Firestore.instance.document("users/$email").get();
  store.dispatch(new ActionClearLoading());
  return !documentSnapshot.exists;
}

void signUp(BuildContext context, Store<RegisterState> store) async {
  store.dispatch(new ActionSetLoading());
  try {
    Map<String, dynamic> fields = store.state.fields.map(
        (key, value) {
          if (value.data is UserRole) {
            return new MapEntry<String, String>(key, value.data.toString());
          }
          return new MapEntry<String, dynamic>(key, value.data);
        });
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
    store.dispatch(new ActionCleanFields());
  } catch (e) {
    Scaffold
        .of(context)
        .showSnackBar(new SnackBar(content: new Text(e.toString())));
  }
  store.dispatch(new ActionClearLoading());
}
