import 'dart:async';

import 'package:flutter/material.dart';
import "package:redux/redux.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:tuberculos/utils.dart";

class RegisterField {
  TextEditingController controller;
  String hint;
  String error;

  RegisterField({
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

  @override
  String toString() {
    return controller.text;
  }

  InputDecoration get decoration => new InputDecoration(
        hintText: hint,
        errorText: error,
      );

  String get data => controller.text;
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

class ActionChooseRole {
  UserRole role;
  ActionChooseRole(this.role);
}

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
          "email": new RegisterField(hint: "E-mail"),
          "password": new RegisterField(hint: "Password"),
          "firstName": new RegisterField(hint: "First Name"),
          "lastName": new RegisterField(hint: "Last Name"),
          "role": UserRole.pasien,
          "apotekerUsername": null,
          "sipa": new RegisterField(hint: "No. SIPA"),
          "alamat": new RegisterField(hint: "Alamat"),
          "namaApotek": new RegisterField(hint: "Nama Apotek"),
          "alamatApotek": new RegisterField(hint: "Alamat Apotek"),
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
  } else if (action is ActionChooseRole) {
    Map<String, dynamic> fields = new Map.from(state.fields);
    fields["role"] = action.role;
    newState = state.clone(fields: fields);
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
