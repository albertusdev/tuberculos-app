import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/redux/configure_store.dart';

@immutable
class InputAlarmState {
  final bool isLoading;
  final Pasien selectedPasien;
  final Obat selectedObat;
  final TimeOfDay timeOfDay;
  final int occurence;
  final String message;
  final List<DateTime> dateTimes;

  InputAlarmState({
    this.isLoading = false,
    this.selectedPasien,
    this.selectedObat,
    this.timeOfDay,
    this.occurence,
    this.message,
    this.dateTimes,
  });

  InputAlarmState cloneWithModified({
    bool isLoading,
    Pasien selectedPasien,
    Obat selectedObat,
    TimeOfDay timeOfDay,
    int occurence,
    String message,
    List<DateTime> dateTimes,
  }) {
    return new InputAlarmState(
      isLoading: isLoading ?? this.isLoading,
      selectedPasien: selectedPasien ?? this.selectedPasien,
      selectedObat: selectedObat ?? this.selectedObat,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      occurence: occurence ?? this.occurence,
      message: message ?? this.message,
      dateTimes: dateTimes ?? this.dateTimes,
    );
  }

  @override
  int get hashCode =>
      super.hashCode ^
      isLoading.hashCode ^
      selectedPasien.hashCode ^
      selectedObat.hashCode ^
      timeOfDay.hashCode ^
      occurence.hashCode ^
      message.hashCode;

  @override
  bool operator ==(other) {
    return identical(this, other) ||
        (this.isLoading == other.isLoading &&
            this.selectedPasien == other.selectedPasien &&
            this.selectedObat == other.selectedObat &&
            this.timeOfDay == other.timeOfDay &&
            this.occurence == other.occurence &&
            this.message == other.message);
  }
}

class ActionInputAlarmSetLoading {}

class ActionInputAlarmClearLoading {}

class ActionInputAlarmSetSelectedPasien {
  final Pasien selectedPasien;
  ActionInputAlarmSetSelectedPasien(this.selectedPasien);
}

class ActionInputAlarmSetSelectedObat {
  final Obat selectedObat;
  ActionInputAlarmSetSelectedObat(this.selectedObat);
}

class ActionInputAlarmSetTimeOfDay {
  final TimeOfDay timeOfDay;
  ActionInputAlarmSetTimeOfDay(this.timeOfDay);
}

class ActionInputAlarmSetOccurence {
  final int occurence;
  ActionInputAlarmSetOccurence(this.occurence);
}

class ActionInputAlarmSetMessage {
  final String message;
  ActionInputAlarmSetMessage(this.message);
}

InputAlarmState dailyAlarmReducer(InputAlarmState state, action) {
  InputAlarmState newState;
  if (action is ActionInputAlarmClearLoading) {
    newState = state.cloneWithModified(isLoading: false);
  } else if (action is ActionInputAlarmSetLoading) {
    newState = state.cloneWithModified(isLoading: true);
  } else if (action is ActionInputAlarmSetSelectedPasien) {
    newState = state.cloneWithModified(selectedPasien: action.selectedPasien);
  } else if (action is ActionInputAlarmSetSelectedObat) {
    newState = state.cloneWithModified(selectedObat: action.selectedObat);
  } else if (action is ActionInputAlarmSetTimeOfDay) {
    newState = state.cloneWithModified(timeOfDay: action.timeOfDay);
  } else if (action is ActionInputAlarmSetOccurence) {
    newState = state.cloneWithModified(occurence: action.occurence);
  } else if (action is ActionInputAlarmSetMessage) {
    newState = state.cloneWithModified(message: action.message);
  } else {
    newState = state;
  }
  return newState;
}

void createDailyAlarm(Store<AppState> store) async {
  store.dispatch(new ActionInputAlarmSetLoading());

  store.dispatch(new ActionInputAlarmClearLoading());
}
