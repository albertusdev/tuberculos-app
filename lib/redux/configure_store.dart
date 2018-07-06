import "dart:convert";

import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import "package:redux/redux.dart";
import "package:redux_persist/redux_persist.dart";
import "package:redux_persist_flutter/redux_persist_flutter.dart";
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/redux/modules/input_alarm/input_alarm.dart';
import "package:tuberculos/redux/modules/register/register.dart";

export "modules/register/register.dart";

@immutable
class AppState {
  final User currentUser;

  final RegisterState registerState;

  final InputAlarmState inputAlarmState;

  // Singleton in App
  final GoogleSignIn googleSignIn;

  AppState(
      {User currentUser,
      GoogleSignIn googleSignIn,
      RegisterState registerState,
      InputAlarmState dailyAlarmState})
      : this.currentUser = currentUser,
        this.registerState = registerState ?? new RegisterState(),
        this.googleSignIn = googleSignIn ?? new GoogleSignIn(),
        this.inputAlarmState = dailyAlarmState ?? new InputAlarmState(timestamps: []);

  AppState cloneWithModified({
    InputAlarmState dailyAlarmState,
    User currentUser,
    RegisterState registerState,
  }) {
    return new AppState(
      currentUser: currentUser ?? this.currentUser,
      dailyAlarmState: dailyAlarmState ?? this.inputAlarmState,
      registerState: registerState ?? this.registerState,
      googleSignIn: this.googleSignIn,
    );
  }

  static AppState fromJson(dynamic prevJson) {
    Map<String, dynamic> userJson = json.decode(prevJson["currentUser"]);
    return new AppState(
        currentUser: new User.createSpecificUserFromJson(userJson));
  }

  dynamic toJson() => {
        "currentUser":
            json.encode(currentUser.toJson()..remove("dateTimeCreated"))
      };

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is AppState) {
      return currentUser == other.currentUser &&
          registerState == other.registerState &&
          inputAlarmState == other.inputAlarmState;
    }
    return false;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      currentUser.hashCode ^
      registerState.hashCode ^
      inputAlarmState.hashCode ^
      googleSignIn.hashCode;
}

AppState reducer(AppState state, action) {
  if (action is PersistLoadedAction<AppState>) {
    return action.state ?? state;
  }
  if (action is ActionChangeCurrentUser) {
    return state.cloneWithModified(currentUser: action.currentUser);
  }
  return state.cloneWithModified(
    dailyAlarmState: dailyAlarmReducer(state.inputAlarmState, action),
    registerState: registerReducer(
      state.registerState,
      action,
    ),
  );
}

class ActionChangeCurrentUser {
  final User currentUser;
  ActionChangeCurrentUser({this.currentUser});
}

Map<String, dynamic> configureStore() {
  final persistor = new Persistor<AppState>(
    storage: new FlutterStorage("tbcls"),
    decoder: AppState.fromJson,
    rawTransforms: new RawTransforms(onSave: [
      (json) {
        return json;
      },
    ]),
  );
  final store = new Store<AppState>(
    reducer,
    initialState: new AppState(),
    middleware: [persistor.createMiddleware()],
  );

  return {
    "store": store,
    "persistor": persistor,
  };
}
