import "dart:convert";

import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import "package:redux/redux.dart";
import "package:redux_persist/redux_persist.dart";
import "package:redux_persist_flutter/redux_persist_flutter.dart";
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/redux/modules/daily_alarm/daily_alarm.dart';
import "package:tuberculos/redux/modules/register/register.dart";

export "modules/register/register.dart";

@immutable
class AppState {
  final User currentUser;

  final RegisterState registerState;

  final DailyAlarmState dailyAlarmState;

  // Singleton in App
  final GoogleSignIn googleSignIn;

  AppState(
      {User currentUser,
      GoogleSignIn googleSignIn,
      RegisterState registerState,
      DailyAlarmState dailyAlarmState})
      : this.currentUser = currentUser,
        this.registerState = registerState ?? new RegisterState(),
        this.googleSignIn = googleSignIn ?? new GoogleSignIn(),
        this.dailyAlarmState = dailyAlarmState ?? new DailyAlarmState();

  AppState cloneWithModified({
    DailyAlarmState dailyAlarmState,
    User currentUser,
    RegisterState registerState,
  }) {
    return new AppState(
      currentUser: currentUser ?? this.currentUser,
      dailyAlarmState: dailyAlarmState ?? this.dailyAlarmState,
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
          dailyAlarmState == other.dailyAlarmState;
    }
    return false;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      currentUser.hashCode ^
      registerState.hashCode ^
      dailyAlarmState.hashCode ^
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
    dailyAlarmState: dailyAlarmReducer(state.dailyAlarmState, action),
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
