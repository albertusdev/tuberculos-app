import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/redux/configure_store.dart';

@immutable
class DailyAlarmState {
  final bool isLoading;
  final Pasien selectedPasien;
  final Obat selectedObat;
  final TimeOfDay timeOfDay;
  final int occurence;
  final String message;

  DailyAlarmState({
    this.isLoading = false,
    this.selectedPasien,
    this.selectedObat,
    this.timeOfDay,
    this.occurence,
    this.message,
  });

  DailyAlarmState cloneWithModified({
    bool isLoading,
    Pasien selectedPasien,
    Obat selectedObat,
    TimeOfDay timeOfDay,
    int occurence,
    String message,
  }) {
    return new DailyAlarmState(
      isLoading: isLoading ?? this.isLoading,
      selectedPasien: selectedPasien ?? this.selectedPasien,
      selectedObat: selectedObat ?? this.selectedObat,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      occurence: occurence ?? this.occurence,
      message: message ?? this.message,
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

class ActionDailyAlarmSetLoading {}

class ActionDailyAlarmClearLoading {}

class ActionDailyAlarmSetSelectedPasien {
  final Pasien selectedPasien;
  ActionDailyAlarmSetSelectedPasien(this.selectedPasien);
}

class ActionDailyAlarmSetSelectedObat {
  final Obat selectedObat;
  ActionDailyAlarmSetSelectedObat(this.selectedObat);
}

class ActionDailyAlarmSetTimeOfDay {
  final TimeOfDay timeOfDay;
  ActionDailyAlarmSetTimeOfDay(this.timeOfDay);
}

class ActionDailyAlarmSetOccurence {
  final int occurence;
  ActionDailyAlarmSetOccurence(this.occurence);
}

class ActionDailyAlarmSetMessage {
  final String message;
  ActionDailyAlarmSetMessage(this.message);
}

DailyAlarmState dailyAlarmReducer(DailyAlarmState state, action) {
  DailyAlarmState newState;
  if (action is ActionDailyAlarmClearLoading) {
    newState = state.cloneWithModified(isLoading: false);
  } else if (action is ActionDailyAlarmSetLoading) {
    newState = state.cloneWithModified(isLoading: true);
  } else if (action is ActionDailyAlarmSetSelectedPasien) {
    newState = state.cloneWithModified(selectedPasien: action.selectedPasien);
  } else if (action is ActionDailyAlarmSetSelectedObat) {
    newState = state.cloneWithModified(selectedObat: action.selectedObat);
  } else if (action is ActionDailyAlarmSetTimeOfDay) {
    newState = state.cloneWithModified(timeOfDay: action.timeOfDay);
  } else if (action is ActionDailyAlarmSetOccurence) {
    newState = state.cloneWithModified(occurence: action.occurence);
  } else if (action is ActionDailyAlarmSetMessage) {
    newState = state.cloneWithModified(message: action.message);
  } else {
    newState = state;
  }
  return newState;
}

void createDailyAlarm(Store<AppState> store) async {
  store.dispatch(new ActionDailyAlarmSetLoading());

  store.dispatch(new ActionDailyAlarmClearLoading());
}
