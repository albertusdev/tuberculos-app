import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/services/api.dart';

class Timestamp {
  DateTime date;
  TimeOfDay timeOfDay;

  Timestamp(this.date, this.timeOfDay);
}

@immutable
class InputAlarmState {
  final bool isLoading;
  final Pasien selectedPasien;
  final Obat selectedObat;
  final TimeOfDay timeOfDay;
  final int occurrence;
  final String message;
  final List<Timestamp> timestamps;

  InputAlarmState({
    this.isLoading = false,
    this.selectedPasien,
    this.selectedObat,
    this.timeOfDay,
    this.occurrence,
    this.message,
    this.timestamps,
  });

  InputAlarmState cloneWithModified({
    bool isLoading,
    Pasien selectedPasien,
    Obat selectedObat,
    TimeOfDay timeOfDay,
    int occurence,
    String message,
    List<Timestamp> timestamps,
  }) {
    return new InputAlarmState(
      isLoading: isLoading ?? this.isLoading,
      selectedPasien: selectedPasien ?? this.selectedPasien,
      selectedObat: selectedObat ?? this.selectedObat,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      occurrence: occurence ?? this.occurrence,
      message: message ?? this.message,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  @override
  int get hashCode =>
      super.hashCode ^
      isLoading.hashCode ^
      selectedPasien.hashCode ^
      selectedObat.hashCode ^
      timeOfDay.hashCode ^
      occurrence.hashCode ^
      message.hashCode;

  @override
  bool operator ==(other) {
    return identical(this, other) ||
        (this.isLoading == other.isLoading &&
            this.selectedPasien == other.selectedPasien &&
            this.selectedObat == other.selectedObat &&
            this.timeOfDay == other.timeOfDay &&
            this.occurrence == other.occurrence &&
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

class ActionInputAlarmSetOccurrence {
  final int occurrence;
  ActionInputAlarmSetOccurrence(this.occurrence);
}

class ActionInputAlarmSetMessage {
  final String message;
  ActionInputAlarmSetMessage(this.message);
}

class ActionInputAlarmAddTimestamp {}

class ActionInputAlarmSetTimestamp {
  int index;
  Timestamp timestamp;
  ActionInputAlarmSetTimestamp(this.index, this.timestamp);
}

class ActionInputAlarmRemoveTimestamp {
  int index;
  ActionInputAlarmRemoveTimestamp(this.index);
}

class ActionInputAlarmReset {}

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
  } else if (action is ActionInputAlarmSetOccurrence) {
    newState = state.cloneWithModified(occurence: action.occurrence);
  } else if (action is ActionInputAlarmSetMessage) {
    newState = state.cloneWithModified(message: action.message);
  } else if (action is ActionInputAlarmReset) {
    newState = new InputAlarmState(timestamps: []);
  } else if (action is ActionInputAlarmAddTimestamp) {
    List<Timestamp> timestamps = new List()..addAll(state.timestamps);
    DateTime last = new DateTime.now();
    last = last.add(new Duration(minutes: 5 * (state.timestamps.length + 1)));
    timestamps.add(new Timestamp(
        last, new TimeOfDay(hour: last.hour, minute: last.minute)));
    newState = state.cloneWithModified(timestamps: timestamps);
  } else if (action is ActionInputAlarmSetTimestamp) {
    List<Timestamp> timestamps = new List()..addAll(state.timestamps);
    timestamps[action.index] = action.timestamp;
    newState = state.cloneWithModified(timestamps: timestamps);
  } else if (action is ActionInputAlarmRemoveTimestamp) {
    List<Timestamp> timestamps = new List();
    for (int i = 0; i < state.timestamps.length; ++i) {
      if (i != action.index) timestamps.add(state.timestamps[i]);
    }
    newState = state.cloneWithModified(timestamps: timestamps);
  } else {
    newState = state;
  }
  return newState;
}

List<DateTime> generateDateTimesFromDailyOccurrence(
    TimeOfDay timeOfDay, int occurrence,
    [DateTime startDate]) {
  if (startDate == null) startDate = new DateTime.now();
  List<DateTime> dateTimes = [];
  int minutesDifferenceFromNow = (timeOfDay.hour * 60 + timeOfDay.minute) -
      (startDate.hour * 60 + startDate.minute);
  if (minutesDifferenceFromNow > 0) {
    startDate = startDate.add(new Duration(minutes: minutesDifferenceFromNow));
  } else {
    startDate = startDate.add(new Duration(
        minutes: 24 * 60 - (startDate.hour * 60 + startDate.minute)));
    startDate = startDate
        .add(new Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute));
  }
  for (int i = 0; i < occurrence; ++i) {
    print(startDate.toString());
    dateTimes.add(startDate);
    startDate = startDate.add(new Duration(days: 1));
  }
  return dateTimes;
}

Future<void> createDailyAlarm(InputAlarmState state) async {
  List<DateTime> dateTimes =
      generateDateTimesFromDailyOccurrence(state.timeOfDay, state.occurrence);
  await createAlarms(
      pasien: state.selectedPasien,
      obat: state.selectedObat,
      message: state.message,
      dateTimes: dateTimes);
}

Future<void> createCustomAlarm(InputAlarmState state) async {
  List<DateTime> dateTimes = state.timestamps
      .map((Timestamp timestamp) => new DateTime(
          timestamp.date.year,
          timestamp.date.month,
          timestamp.date.day,
          timestamp.timeOfDay.hour,
          timestamp.timeOfDay.minute))
      .toList();
  await createAlarms(
      pasien: state.selectedPasien,
      obat: state.selectedObat,
      message: state.message,
      dateTimes: dateTimes);
}
