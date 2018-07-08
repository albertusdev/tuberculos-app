import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:tuberculos/models/alarm.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/screens/show_obat_screen.dart';
import 'package:tuberculos/services/api.dart';

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
          title: new Text("Obat Tersisa", style: new TextStyle(
            color: Theme.of(context).primaryColorDark,
          )),
          subtitle: new Text(obat.name, style: new TextStyle(
            color: Theme.of(context).primaryColor,
            fontStyle: FontStyle.italic,
          )),
          trailing: new Container(
            child: new Column(
              children: <Widget>[
                new Text("$frequency", style:new TextStyle(color: Colors.white, fontSize: 24.0)),
                new Text("Butir", style: new TextStyle(color: Colors.white)),
              ],
            ),
            padding: new EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.circular(12.0),
              color: Theme.of(context).primaryColor,
            )
          ),
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

class PasienAlarmScreen extends StatelessWidget {
  Pasien pasien;

  PasienAlarmScreen(this.pasien);

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: new EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        child: new Column(
          children: <Widget>[
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
                        "Belum ada obat yang terjadwal untuk mu. Silahkan hubungi Apoteker mu ya :)",
                        textAlign: TextAlign.center,
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
