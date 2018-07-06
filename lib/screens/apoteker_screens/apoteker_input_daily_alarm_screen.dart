import "package:flutter/material.dart";
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/redux/configure_store.dart';
import 'package:tuberculos/redux/modules/input_alarm/input_alarm.dart';
import 'package:tuberculos/screens/apoteker_screens/apoteker_choose_obat_dialog.dart';
import 'package:tuberculos/screens/input_screen.dart';
import "package:tuberculos/services/api.dart";
import 'package:tuberculos/widgets/choose_pasien_dialog.dart';
import 'package:tuberculos/widgets/full_width_widget.dart';

class ApotekerInputDailyAlarmScreen extends StatelessWidget {
  _handleSubmit(BuildContext context, Store<AppState> store) async {
    try {
      InputAlarmState state = store.state.inputAlarmState;
      if (state.selectedPasien == null) {
        throw "Pasien tidak boleh kosong.";
      }
      if (state.selectedObat == null) {
        throw "Obat tidak boleh kosong.";
      }
      if (state.timeOfDay == null) {
        throw "Waktu tidak boleh kosong.";
      }
      if (state.occurrence == null) {
        throw "Frekuensi tidak boleh kosong.";
      }
      if (state.message == null) {
        throw "Pesan tidak boleh kosong.";
      }
      store.dispatch(new ActionInputAlarmSetLoading());
      await createDailyAlarm(store.state.inputAlarmState);
      store.dispatch(new ActionInputAlarmClearLoading());
      Navigator.pop(context, store.state.inputAlarmState.selectedPasien);
    } catch (e) {
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text(e.toString())));
      store.dispatch(new ActionInputAlarmClearLoading());
    }
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, Store<AppState> store) {
    List<Widget> bottomNavigationBarChildren = [];
    bool isLoading = store.state.inputAlarmState.isLoading;
    if (isLoading)
      bottomNavigationBarChildren.add(new LinearProgressIndicator());
    bottomNavigationBarChildren.add(new FullWidthWidget(
        child: new RaisedButton(
      child: new Text("Tambahkan",
          style: new TextStyle(
            color: Colors.white,
          )),
      onPressed: () => isLoading ? null : _handleSubmit(context, store),
    )));
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: bottomNavigationBarChildren,
    );
  }

  void _handleInputTimeOfDay(
      BuildContext context, Store<AppState> store) async {
    TimeOfDay timeOfDay = await showTimePicker(
        context: context, initialTime: new TimeOfDay(hour: 09, minute: 00));
    if (timeOfDay != null) {
      store.dispatch(new ActionInputAlarmSetTimeOfDay(timeOfDay));
    }
  }

  void _handleInputOccurrence(
      BuildContext context, Store<AppState> store) async {
    String occurrenceString =
        await Navigator.of(context).push<String>(new MaterialPageRoute(
              builder: (_) => new NumberInputScreen(
                  title: "Frekuensi",
                  hintText: "Masukkan frekuensi harian obat"),
            ));
    if (occurrenceString != null && occurrenceString.isNotEmpty) {
      try {
        int occurrence = int.parse(occurrenceString);
        store.dispatch(new ActionInputAlarmSetOccurrence(occurrence));
      } catch (e) {
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Seluruh digit harus merupakan angka.")));
      }
    }
  }

  void _handleInputMessage(BuildContext context, Store<AppState> store) async {
    String message =
        await Navigator.of(context).push<String>(new MaterialPageRoute(
              builder: (_) => new MultiLineInputScreen(
                  title: "Pesan kepada Pasien",
                  hintText: "Masukkan pesan yang ingin disampaikan"),
            ));
    if (message != null && message.isNotEmpty) {
      store.dispatch(new ActionInputAlarmSetMessage(message));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(
        builder: (BuildContext build, Store<AppState> store) {
      return new Scaffold(
        appBar: new AppBar(
            title: new Text("Pengingat",
                style: new TextStyle(
                  letterSpacing: 1.0,
                ))),
        body: new Builder(
          builder: (context) => new Container(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Container(
                        alignment: Alignment.topLeft,
                        child: new Text(
                          "Email Pasien yang dituju",
                          style: new TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        margin: new EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      new FullWidthWidget(
                        child: new OutlineButton(
                          child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                store.state.inputAlarmState.selectedPasien ==
                                        null
                                    ? new Text(
                                        "Pilih Email",
                                        style: new TextStyle(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : new Text(
                                        store.state.inputAlarmState
                                            .selectedPasien.displayName,
                                        style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                new Icon(Icons.menu,
                                    color: Theme.of(context).disabledColor),
                              ]),
                          onPressed: () {
                            showDialog<Pasien>(
                                context: context,
                                builder: (context) {
                                  return new ChoosePasienDialog(
                                      getPasiensCollectionReference(
                                          store.state.currentUser.email));
                                }).then(
                              (Pasien pasien) {
                                store.dispatch(
                                    new ActionInputAlarmSetSelectedPasien(
                                        pasien));
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                new Container(
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Container(
                        alignment: Alignment.topLeft,
                        child: new Text(
                          "Obat yang harus dikonsumsi",
                          style: new TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        margin: new EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      new FullWidthWidget(
                        child: new OutlineButton(
                          child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                store.state.inputAlarmState.selectedObat == null
                                    ? new Text(
                                        "Pilih Obat",
                                        style: new TextStyle(
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                      )
                                    : new Text(
                                        store.state.inputAlarmState.selectedObat
                                            .name,
                                        style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                new Icon(Icons.menu,
                                    color: Theme.of(context).disabledColor),
                              ]),
                          onPressed: () {
                            showDialog<Obat>(
                                context: context,
                                builder: (context) {
                                  return new ApotekerChooseObatDialog(null);
                                }).then(
                              (Obat selectedObat) {
                                store.dispatch(
                                  new ActionInputAlarmSetSelectedObat(
                                      selectedObat),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      new Container(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Flexible(
                                child: new Container(
                              child: new Column(
                                children: <Widget>[
                                  new Container(
                                    child: new Text(
                                      "Jam",
                                      style: new TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    margin: new EdgeInsets.only(bottom: 8.0),
                                  ),
                                  new OutlineButton(
                                    child: new Text(
                                      store.state.inputAlarmState.timeOfDay
                                              ?.format(context) ??
                                          "09.00 AM",
                                      style: new TextStyle(
                                        color: store.state.inputAlarmState
                                                    .timeOfDay ==
                                                null
                                            ? Theme.of(context).disabledColor
                                            : Colors.black,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _handleInputTimeOfDay(context, store),
                                  )
                                ],
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            )),
                            new Flexible(
                              child: new Container(
                                child: new Column(
                                  children: <Widget>[
                                    new Container(
                                      child: new Text(
                                        "Frekuensi",
                                        style: new TextStyle(
                                          color: Theme
                                              .of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      margin: new EdgeInsets.only(bottom: 8.0),
                                    ),
                                    new Row(
                                      children: <Widget>[
                                        new Container(
                                          child: new Text(
                                            "1 X ",
                                            style: new TextStyle(
                                              color: Theme
                                                  .of(context)
                                                  .primaryColor,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                          margin:
                                              new EdgeInsets.only(right: 4.0),
                                        ),
                                        new OutlineButton(
                                          child: new Text(
                                            store.state.inputAlarmState
                                                    .occurrence
                                                    ?.toString() ??
                                                "2",
                                            style: new TextStyle(
                                              color: store.state.inputAlarmState
                                                          .occurrence ==
                                                      null
                                                  ? Theme
                                                      .of(context)
                                                      .disabledColor
                                                  : Colors.black,
                                            ),
                                          ),
                                          onPressed: () =>
                                              _handleInputOccurrence(
                                                  context, store),
                                        )
                                      ],
                                    ),
                                  ],
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                                margin: new EdgeInsets.only(right: 8.0),
                              ),
                            ),
                          ],
                        ),
                        margin: new EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      new Container(
                        alignment: Alignment.topLeft,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                                child: new Text(
                                  "Pesan yang ingin disampaikan",
                                  style: new TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                margin: new EdgeInsets.only(bottom: 8.0)),
                            new FullWidthWidget(
                              child: new OutlineButton(
                                child: new Container(
                                  alignment: Alignment.topLeft,
                                  child: new Text(
                                    store.state.inputAlarmState.message ??
                                        "Masukkan pesan yang ingin disampaikan",
                                    style: new TextStyle(
                                      color:
                                          store.state.inputAlarmState.message ==
                                                  null
                                              ? Theme.of(context).disabledColor
                                              : Colors.black,
                                    ),
                                  ),
                                  height: 128.0,
                                ),
                                padding: new EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                onPressed: () =>
                                    _handleInputMessage(context, store),
                              ),
                            )
                          ],
                        ),
                        margin: new EdgeInsets.only(top: 16.0),
                      ),
                    ],
                  ),
                  margin: new EdgeInsets.only(bottom: 8.0),
                ),
                new Container(),
              ],
            ),
            margin: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          ),
        ),
        bottomNavigationBar: new Builder(
          builder: (BuildContext context) =>
              _buildBottomNavigationBar(context, store),
        ),
      );
    });
  }
}
