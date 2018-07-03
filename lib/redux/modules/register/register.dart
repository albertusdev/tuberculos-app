import 'dart:async';

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/material.dart';
import 'package:flutter_one_signal/flutter_one_signal.dart';
import "package:google_sign_in/google_sign_in.dart";
import "package:redux/redux.dart";
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/redux/configure_store.dart';
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

  User choosenUser;
  Apoteker apoteker;
  Pasien pasien;

  String email;
  String role;

  RegisterState({
    bool isLoading,
    GoogleSignIn googleSignIn,
    Map<String, RegisterField> apotekerFields,
    Map<String, RegisterField> pasienFields,
    String email,
    String role,
  })  : this.apotekerFields = apotekerFields ??
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
            },
        this.email = email ?? "",
        this.googleSignIn = googleSignIn ?? new GoogleSignIn(),
        this.isLoading = isLoading ?? false,
        this.pasienFields = pasienFields ??
            {
              "alamat": new RegisterFormField(hint: "Alamat"),
              "apoteker": new SimpleField<String>(null, () => null),
              "chatId": new SimpleField<String>("", () => ""),
              "isVerified": new SimpleField<bool>(false, () => false),
              "role": new SimpleField<String>(
                  UserRole.pasien, () => UserRole.pasien),
              "tuberculosStage": new SimpleField(null, () => null),
            },
        this.role = role ?? UserRole.apoteker;

  RegisterState cloneWithModified({
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
  switch (action.runtimeType) {
    case ActionSetLoading: {
      newState = state.cloneWithModified(isLoading: true);
      break;
    }
    case ActionClearLoading:{
      newState = state.cloneWithModified(isLoading: false);
      break;
    }
    case ActionSetApotekerField: {
      Map<String, RegisterField> fields = new Map.from(state.apotekerFields);
      fields[action.key] = action.value;
      newState = state.cloneWithModified(apotekerFields: fields);
      break;
    }
    case ActionSetPasienField: {
      Map<String, RegisterField> fields = new Map.from(state.pasienFields);
      fields[action.key] = action.value;
      newState = state.cloneWithModified(pasienFields: fields);
      break;
    }
    case ActionClearApotekerFields: {
      Map<String, RegisterField> fields = state.apotekerFields.map((key, val) {
        val.clear();
        return new MapEntry<String, RegisterField>(key, val);
      });
      newState = state.cloneWithModified(apotekerFields: fields);
      break;
    }
    case ActionClearPasienFields: {
      Map<String, RegisterField> fields = state.pasienFields.map((key, val) {
        val.clear();
        return new MapEntry<String, RegisterField>(key, val);
      });
      newState = state.cloneWithModified(pasienFields: fields);
      break;
    }
    case ActionSetEmail: {
      newState = state.cloneWithModified(email: action.email);
      break;
    }
    case ActionSetRole: {
      newState = state.cloneWithModified(role: action.role);
      break;
    }
    default: {
      newState = state;
      break;
    }
  }

  return newState;
}


// Method to POST a User into Firestore Database
// Assumption here is user have choosen their Google Account (Have signed in)
Future<User> signUp(Store<AppState> store) async {
  GoogleSignInAccount googleSignInAccount =
      store.state.googleSignIn.currentUser;
  assert(googleSignInAccount != null);

  store.dispatch(new ActionSetLoading());

  RegisterState state = store.state.registerState;

  // Deserialize from RegisterField
  Map<String, dynamic> fields = state.fields
      .map((key, value) => new MapEntry<String, dynamic>(key, value.data));

  // Important to user User.createSpecificUserFromJson
  fields["role"] = state.role;

  // Generate important user fields
  User user  = new User.createSpecificUserFromJson(fields);
  user.dateTimeCreated = new DateTime.now();
  user.displayName = googleSignInAccount.displayName;
  user.photoUrl = googleSignInAccount.photoUrl;
  user.email = googleSignInAccount.email;
  user.oneSignalPlayerId = await FlutterOneSignal.getUserId();

  // Create new chat room if it's user
  if (user is Pasien) {
    DocumentReference chatRef = await createNewMessageDocument({
      "apoteker": user.apoteker,
      "pasien": user.email,
    });
    user.chatId = chatRef.documentID;
  }

  setUser(user);
  await signInFirebaseWithGoogleSignIn(store.state.googleSignIn);

  store.dispatch(new ActionChangeCurrentUser(currentUser: user));
  store.dispatch(new ActionClearApotekerFields());
  store.dispatch(new ActionClearPasienFields());
  store.dispatch(new ActionClearLoading());

  return user;
}
