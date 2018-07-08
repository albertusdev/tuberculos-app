import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import "package:flutter_circular_chart/flutter_circular_chart.dart";
import 'package:tuberculos/models/alarm.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/screens/show_obat_screen.dart';
import "package:tuberculos/services/api.dart";
import 'package:tuberculos/widgets/full_width_widget.dart';
import 'package:tuberculos/widgets/verify_pasien_dialog.dart';

class ObatCard extends StatelessWidget {
  final Obat obat;
  final int frequency;

  ObatCard({Key key, this.obat, this.frequency});

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: new EdgeInsets.symmetric(vertical: 8.0),
        child: new FullWidthWidget(
            child: new RaisedButton(
          color: Colors.white,
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(obat.name,
                    style:
                        new TextStyle(color: Theme.of(context).primaryColor)),
                new Text("$frequency butir",
                    style:
                        new TextStyle(color: Theme.of(context).primaryColor)),
              ]),
          onPressed: () {
            Navigator.of(context).push(new MaterialPageRoute(
                  builder: (_) => new ShowObatScreen(obat),
                ));
          },
        )));
  }
}

class PasienStatisticScreen extends StatefulWidget {
  final Pasien pasien;

  PasienStatisticScreen({Key key, this.pasien}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _PasienStatisticScreenState(this.pasien);
}

class _PasienStatisticScreenState extends State<PasienStatisticScreen> {
  final Pasien pasien;

  _PasienStatisticScreenState(this.pasien);

  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();

  Widget _getHeader() {
    return new Container(
      margin: new EdgeInsets.only(bottom: 8.0),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            child: new Text(
              "Tahapan Tuberculos",
              style: new TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 16.0,
              ),
            ),
            margin: new EdgeInsets.only(bottom: 8.0),
          ),
          new Container(
            child: new FullWidthWidget(
              child: new OutlineButton(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(pasien.tuberculosStage == 0
                          ? "Tahap Awal"
                          : "Tahap Lanjutan"),
                      new Icon(Icons.menu,
                          color: Theme.of(context).disabledColor),
                    ],
                  ),
                  onPressed: () {
                    showDialog<int>(
                      context: context,
                      builder: (BuildContext context) =>
                          new VerifyPasienDialog(pasien: pasien),
                    ).then((int tuberculosStage) {
                      pasien.tuberculosStage = tuberculosStage;
                      setState(() {});
                    });
                  }),
            ),
            margin: new EdgeInsets.only(bottom: 16.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(pasien.displayName)),
      body: new Container(
        margin: new EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _getHeader(),
            new Expanded(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new StreamBuilder(
                      stream: getPasienAlarmsCollectionReference(pasien)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return new Flexible(
                            flex: 1,
                            child: new Center(
                                child: new CircularProgressIndicator()),
                          );
                        }

                        final List<Alarm> alarms = snapshot.data.documents
                            .map((DocumentSnapshot documentSnapshot) =>
                                new Alarm.fromJson(documentSnapshot.data))
                            .toList();

                        DateTime now = new DateTime.now();
                        final lateAlarms = alarms.where(
                            (Alarm alarm) => alarm.dateTime.compareTo(now) < 0);

                        if (lateAlarms.length == 0) {
                          return new Flexible(
                            flex: 1,
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text("Obat yang telah diminum",
                                    style: new TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 16.0,
                                    )),
                                new Expanded(
                                  child: new Container(
                                    alignment: Alignment.center,
                                    child: new Text(
                                        "Pasien ini belum pernah minum obat."),
                                  ),
                                )
                              ],
                            ),
                          );
                        }

                        final int takenAlarm = lateAlarms.fold(
                            0,
                            (prev, Alarm alarm) =>
                                alarm.taken ? prev + 1 : prev);
                        return new Flexible(
                          flex: 2,
                          child: new Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                "Ketepatan minum obat",
                                style: new TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 16.0,
                                ),
                              ),
                              new Container(
                                  alignment: Alignment.center,
                                  margin: new EdgeInsets.only(top: 8.0),
                                  child: new AnimatedCircularChart(
                                    key: _chartKey,
                                    size: new Size(128.0, 128.0),
                                    initialChartData: <CircularStackEntry>[
                                      new CircularStackEntry(
                                        <CircularSegmentEntry>[
                                          new CircularSegmentEntry(
                                            takenAlarm /
                                                (lateAlarms.length.toDouble()) *
                                                100,
                                            Theme.of(context).primaryColor,
                                            rankKey: 'completed',
                                          ),
                                          new CircularSegmentEntry(
                                            (lateAlarms.length - takenAlarm) /
                                                (lateAlarms.length.toDouble()) *
                                                100,
                                            Colors.blueGrey[600],
                                            rankKey: 'remaining',
                                          ),
                                        ],
                                        rankKey: 'progress',
                                      ),
                                    ],
                                    chartType: CircularChartType.Radial,
                                    percentageValues: true,
                                    holeLabel:
                                        "${takenAlarm/lateAlarms.length.toDouble() * 100}%",
                                    labelStyle: new TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.0,
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }),
                  new StreamBuilder(
                      stream: getPasienAlarmsCollectionReference(pasien)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return new CircularProgressIndicator();
                        }

                        final List<Alarm> alarms = snapshot.data.documents
                            .map((DocumentSnapshot documentSnapshot) =>
                                new Alarm.fromJson(documentSnapshot.data))
                            .toList();

                        DateTime now = new DateTime.now();
                        final lateAlarms = alarms.where(
                            (Alarm alarm) => alarm.dateTime.compareTo(now) < 0);

                        if (lateAlarms.length == 0) {
                          return new Flexible(
                            flex: 2,
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text("Obat yang telah diminum",
                                    style: new TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 16.0,
                                    )),
                                new Expanded(
                                  child: new Container(
                                    alignment: Alignment.center,
                                    child: new Text(
                                        "Pasien ini belum pernah minum obat."),
                                  ),
                                )
                              ],
                            ),
                          );
                        }

                        Map<String, Map<String, dynamic>> groupAlarmsByObat =
                            new Map<String, Map<String, dynamic>>();
                        Map<String, Obat> obatById = new Map<String, Obat>();
                        Map<String, int> frequencyByObatId =
                            new Map<String, int>();
                        lateAlarms.forEach((Alarm alarm) {
                          print(alarm.obat.id);
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

                        return new Flexible(
                          flex: 2,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text("Obat yang telah diminum",
                                  style: new TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 16.0,
                                  )),
                              new Expanded(
                                child: new ListView.builder(
                                  itemCount: widgets.length,
                                  itemBuilder: (_, int i) {
                                    return widgets[i];
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
