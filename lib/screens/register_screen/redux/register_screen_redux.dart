import 'dart:async';

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/material.dart';
import "package:google_sign_in/google_sign_in.dart";
import "package:redux/redux.dart";
import 'package:tuberculos/models/user.dart';
import "package:tuberculos/services/api.dart";

abstract class RegisterField<T> {
  T get data;
  void clear();
}

class ActionClearApotekerFields {}

class ActionClearLoading {}

class ActionClearPasienFields {}

class ActionSetApotekerField {
  String key;
  RegisterField value;
  ActionSetApotekerField(this.key, this.value);
}

class ActionSetApotekerFields {
  List<ActionSetPasienField> fields;
  ActionSetApotekerFields(this.fields);
}

class ActionSetEmail {
  String email;
  ActionSetEmail(this.email);
}

class ActionSetLoading {}

class ActionSetPasienField {
  String key;
  RegisterField value;
  ActionSetPasienField(this.key, this.value);
}

class ActionSetPasienFields {
  List<ActionSetApotekerField> fields;
  ActionSetPasienFields(this.fields);
}

class ActionSetRole {
  String role;
  ActionSetRole(this.role);
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

  InputDecoration get decoration =>
      new InputDecoration(hintText: hint, errorText: error);

  @override
  String get data => controller?.text;

  @override
  void clear() {
    controller.clear();
  }
}

class RegisterState {
  static final int maxStep = 3;

  bool isLoading;
  GoogleSignIn googleSignIn;
  Map<String, RegisterField> apotekerFields;
  Map<String, RegisterField> pasienFields;
  String email;
  String role;

  RegisterState({
    bool isLoading,
    GoogleSignIn googleSignIn,
    Map<String, RegisterField> apotekerFields,
    Map<String, RegisterField> pasienFields,
    String email,
    String role,
  }) {
    this.apotekerFields = apotekerFields ??
        {
          "alamatApotek": new RegisterFormField(hint: "Alamat Apotek"),
          "namaApotek": new RegisterFormField(hint: "Nama Apotek"),
          "pasiens": new SimpleField<List>(
            new List(),
            () {
              return new List();
            },
          ),
          "role": new SimpleField<String>(UserRole.apoteker, () {
            return UserRole.apoteker;
          }),
          "sipa": new RegisterFormField(hint: "No. SIPA"),
        };
    this.email = email ?? "";
    this.googleSignIn = googleSignIn ?? new GoogleSignIn();
    this.isLoading = isLoading ?? false;
    this.pasienFields = pasienFields ??
        {
          "alamat": new RegisterFormField(hint: "Alamat"),
          "apoteker": new SimpleField<String>(null, () => null),
          "chatId": new SimpleField<String>("", () => ""),
          "isVerified": new SimpleField<bool>(false, () => false),
          "role":
              new SimpleField<String>(UserRole.pasien, () => UserRole.pasien),
          "tuberculosStage": new SimpleField(null, () => null),
        };
    this.role = role ?? UserRole.apoteker;
  }

  RegisterState clone({
    bool isLoading,
    GoogleSignIn googleSignIn,
    int currentStep,
    Map<String, RegisterField> apotekerFields,
    Map<String, RegisterField> pasienFields,
    String email,
    String role,
  }) {
    return new RegisterState(
      apotekerFields: apotekerFields ?? this.apotekerFields,
      googleSignIn: googleSignIn ?? this.googleSignIn,
      isLoading: isLoading ?? this.isLoading,
      pasienFields: pasienFields ?? this.pasienFields,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  Map<String, RegisterField> get fields =>
      role == UserRole.apoteker ? apotekerFields : pasienFields;
}

class SimpleField<T> implements RegisterField<T> {
  Function generateInitialValueCallback;
  T data;
  SimpleField(this.data, [this.generateInitialValueCallback]);

  @override
  void clear() {
    if (generateInitialValueCallback == null) {
      this.data = null;
    } else {
      this.data = generateInitialValueCallback();
    }
  }
}

RegisterState registerReducer(RegisterState state, action) {
  RegisterState newState = state;
  if (action is ActionSetLoading) {
    newState = state.clone(isLoading: true);
  } else if (action is ActionClearLoading) {
    newState = state.clone(isLoading: false);
  } else if (action is ActionSetApotekerField) {
    Map<String, RegisterField> fields = new Map.from(state.apotekerFields);
    fields[action.key] = action.value;
    newState = state.clone(apotekerFields: fields);
  } else if (action is ActionSetApotekerFields) {
    Map<String, RegisterField> fields = new Map.from(state.apotekerFields);
    action.fields.forEach((field) {
      fields[field.key] = field.value;
    });
    newState = state.clone(apotekerFields: fields);
  } else if (action is ActionSetPasienField) {
    Map<String, RegisterField> fields = new Map.from(state.pasienFields);
    fields[action.key] = action.value;
    newState = state.clone(pasienFields: fields);
  } else if (action is ActionSetPasienFields) {
    Map<String, RegisterField> fields = new Map.from(state.apotekerFields);
    action.fields.forEach((field) {
      fields[field.key] = field.value;
    });
    newState = state.clone(pasienFields: fields);
  } else if (action is ActionClearApotekerFields) {
    Map<String, RegisterField> fields = state.apotekerFields.map((key, val) {
      val.clear();
      return new MapEntry<String, RegisterField>(key, val);
    });
    newState = state.clone(apotekerFields: fields);
  } else if (action is ActionClearPasienFields) {
    Map<String, RegisterField> fields = state.pasienFields.map((key, val) {
      val.clear();
      return new MapEntry<String, RegisterField>(key, val);
    });
    newState = state.clone(pasienFields: fields);
  } else if (action is ActionSetEmail) {
    newState = state.clone(email: action.email);
  } else if (action is ActionSetRole) {
    newState = state.clone(role: action.role);
  } else {
    newState = state;
  }
  return newState;
}

Future<Map<String, dynamic>> signUp(Store<RegisterState> store) async {
  store.dispatch(new ActionSetLoading());
  GoogleSignInAccount googleSignInAccount =
      store.state.googleSignIn.currentUser;
  Map<String, dynamic> fields = store.state.fields
      .map((key, value) => new MapEntry<String, dynamic>(key, value.data));

  fields["dateTimeCreated"] = new DateTime.now();
  if (googleSignInAccount != null) {
    fields["displayName"] = googleSignInAccount.displayName;
    fields["photoUrl"] = googleSignInAccount.photoUrl;
    fields["email"] = googleSignInAccount.email;
  }

  String email = store.state.email;
  String role = store.state.role;

  DocumentReference ref = getUserDocumentReference(role: role, email: email);

  if (role == User.PASIEN) {
    DocumentReference chatRef = await createNewMessageDocument({});
    fields["chatId"] = chatRef.documentID;

    String apotekerEmail = fields["apoteker"];
    DocumentReference duplicatedRef = getNestedPasienDocumentReference(
        apotekerEmail: apotekerEmail, pasienEmail: email);
    await duplicatedRef.setData(fields);
  }

  await ref.setData(fields);
  await signInFirebaseWithGoogleSignIn(store.state.googleSignIn);

  store.dispatch(new ActionClearApotekerFields());
  store.dispatch(new ActionClearPasienFields());
  store.dispatch(new ActionClearLoading());

  return fields;
}
