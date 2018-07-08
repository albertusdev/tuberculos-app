import "dart:async";

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import 'package:tuberculos/models/alarm.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/screens/show_obat_screen.dart';
import 'package:tuberculos/services/api.dart';
import 'package:tuberculos/widgets/full_width_widget.dart';

class ObatCard extends StatelessWidget {
  final Obat obat;
  final int frequency;

  ObatCard({Key key, this.obat, this.frequency});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: new EdgeInsets.symmetric(vertical: 2.0),
        decoration: new BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Theme.of(context).disabledColor,
            )
          ],
        ),
        child: new ListTile(
          isThreeLine: true,
          title: new Text("Obat Tersisa",
              style: new TextStyle(
                color: Theme.of(context).primaryColorDark,
              )),
          subtitle: new Text(obat.name,
              style: new TextStyle(
                color: Theme.of(context).primaryColor,
                fontStyle: FontStyle.italic,
              )),
          trailing: new Container(
              child: new Column(
                children: <Widget>[
                  new Text("$frequency",
                      style:
                          new TextStyle(color: Colors.white, fontSize: 24.0)),
                  new Text("Butir", style: new TextStyle(color: Colors.white)),
                ],
              ),
              padding:
                  new EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(12.0),
                color: Theme.of(context).primaryColor,
              )),
          onTap: () {
            Navigator.of(context).push(new MaterialPageRoute(
                  builder: (_) => new ShowObatScreen(obat),
                ));
          },
          onLongPress: () {
            Navigator.of(context).push(new MaterialPageRoute(
                  builder: (_) => new ShowObatScreen(obat),
                ));
          },
        ));
  }
}

class NearestUpcomingAlarmWidget extends StatefulWidget {
  final Pasien pasien;

  NearestUpcomingAlarmWidget(this.pasien);

  @override
  _NearestUpcomingAlarmWidgetState createState() =>
      _NearestUpcomingAlarmWidgetState(this.pasien);
}

class _NearestUpcomingAlarmWidgetState
    extends State<NearestUpcomingAlarmWidget> {
  final Pasien pasien;

  Timer refresh;

  _NearestUpcomingAlarmWidgetState(this.pasien);

  @override
  void initState() {
    super.initState();
    refresh = new Timer.periodic(new Duration(minutes: 1), (Timer timer) {
      print("Rebuilding...");
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    refresh.cancel();
  }

  Widget _buildTimerDisplayWidget() {
    return new StreamBuilder(
      stream: getPasienAlarmsCollectionReference(pasien).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return new Container(
            child: new CircularProgressIndicator(),
            padding: new EdgeInsets.all(8.0),
          );
        }

        final List<Alarm> alarms = snapshot.data.documents
            .map((DocumentSnapshot documentSnapshot) =>
                new Alarm.fromJson(documentSnapshot.data))
            .toList();

        DateTime now = new DateTime.now();
        final upcomingAlarms = alarms
            .where((Alarm alarm) => alarm.dateTime.compareTo(now) > 0)
            .toList();

        if (upcomingAlarms.length == 0) {
          return new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Flexible(
                flex: 2,
                child: new Text(
                  "--:--",
                  style: new TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 40.0,
                  ),
                ),
              ),
              new Flexible(
                child: new Container(
                  child: new Text(
                    "Tidak ada alarm terdekat",
                    style: new TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w200,
                      fontSize: 16.0,
                    ),
                  ),
                  margin: new EdgeInsets.only(left: 16.0),
                ),
              )
            ],
          );
        }

        upcomingAlarms
            .sort((Alarm a, Alarm b) => a.dateTime.compareTo(b.dateTime));

        final Alarm nearestAlarm = upcomingAlarms.first;

        Duration difference = nearestAlarm.dateTime.difference(new DateTime.now());

        return new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Flexible(
              flex: 2,
              child: new Text(
                new DateFormat.Hm().format(nearestAlarm.dateTime),
                style: new TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 40.0,
                ),
              ),
            ),
            new Flexible(
              child: new Container(
                child: new Text(
                  "${difference.inHours} jam ${difference.inMinutes + (difference.inSeconds / 60.toDouble()).ceil()} menit tersisa",
                  style: new TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w200,
                    fontSize: 16.0,
                  ),
                ),
                margin: new EdgeInsets.only(left: 16.0),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(children: <Widget>[
        new FullWidthWidget(
          child: new Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Theme.of(context).disabledColor,
                )
              ],
            ),
            child: new Text(
              "Jam Minum Obat Terdekat",
              style: new TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 18.0,
              ),
            ),
            padding: new EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            margin: new EdgeInsets.only(bottom: 2.0),
          ),
        ),
        new FullWidthWidget(
          child: new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Theme.of(context).disabledColor,
                )
              ],
            ),
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            child: _buildTimerDisplayWidget(),
          ),
        ),
      ]),
      margin: new EdgeInsets.only(bottom: 24.0),
    );
  }
}

class PasienAlarmScreen extends StatelessWidget {
  final Pasien pasien;

  PasienAlarmScreen(this.pasien);

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: new EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        child: new Column(
          children: <Widget>[
            new NearestUpcomingAlarmWidget(pasien),
            new StreamBuilder(
              stream: getPasienAlarmsCollectionReference(pasien).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return new CircularProgressIndicator();
                }

                final List<Alarm> alarms = snapshot.data.documents
                    .map((DocumentSnapshot documentSnapshot) =>
                        new Alarm.fromJson(documentSnapshot.data))
                    .toList();

                DateTime now = new DateTime.now();
                final upcomingAlarms = alarms
                    .where((Alarm alarm) => alarm.dateTime.compareTo(now) > 0);

                if (upcomingAlarms.length == 0) {
                  return new Expanded(
                    child: new Container(
                      alignment: Alignment.center,
                      child: new Text(
                        "Tidak ada obat yang terjadwal untuk mu. Silahkan hubungi Apoteker mu ya :)",
                        style: new TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      decoration: new BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: <BoxShadow>[
                          new BoxShadow(
                            color: Theme.of(context).disabledColor,
                          )
                        ],
                      ),
                    ),
                  );
                }

                Map<String, Obat> obatById = new Map<String, Obat>();
                Map<String, int> frequencyByObatId = new Map<String, int>();
                upcomingAlarms.forEach((Alarm alarm) {
                  obatById[alarm.obat.id] = alarm.obat;
                  if (frequencyByObatId.containsKey(alarm.obat.id)) {
                    frequencyByObatId[alarm.obat.id] += 1;
                  } else {
                    frequencyByObatId[alarm.obat.id] = 1;
                  }
                });

                List<Widget> widgets = [];
                obatById.forEach((String id, Obat obat) {
                  widgets.add(new ObatCard(
                      obat: obat, frequency: frequencyByObatId[id]));
                });

                return new Expanded(
                  child: new ListView.builder(
                    itemCount: widgets.length,
                    itemBuilder: (_, int i) {
                      return widgets[i];
                    },
                  ),
                );
              },
            ),
          ],
        ));
  }
}
