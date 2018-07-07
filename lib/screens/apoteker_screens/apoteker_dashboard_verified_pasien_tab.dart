import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/screens/apoteker_screens/apoteker_input_custom_alarm_screen.dart';
import 'package:tuberculos/screens/apoteker_screens/apoteker_input_daily_alarm_screen.dart';
import 'package:tuberculos/screens/pasien_statistic_screen.dart';
import 'package:tuberculos/services/api.dart';
import 'package:tuberculos/widgets/user_card.dart';

class VerifiedPasiensTab extends StatefulWidget {
  final Apoteker apoteker;

  VerifiedPasiensTab({Key key, this.apoteker});

  @override
  State<StatefulWidget> createState() => new _VerifiedPasienTabState(apoteker);
}

class _VerifiedPasienTabState extends State<VerifiedPasiensTab> {
  Apoteker apoteker;

  _VerifiedPasienTabState(this.apoteker);

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.all(16.0),
      child: new StreamBuilder<QuerySnapshot>(
        stream: getPasiensCollectionReference(apoteker?.email)?.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          Widget child;
          if (!snapshot.hasData) {
            return new Center(
              child: new CircularProgressIndicator(),
            );
          }
          final data = snapshot.data.documents
              .map((DocumentSnapshot document) =>
                  new Pasien.fromJson(document.data, document.documentID))
              .toList()
                ..retainWhere((pasien) => pasien.isVerified);
          final int dataCount = data.length;
          return new ListView.builder(
            itemCount: dataCount + 1,
            itemBuilder: (_, int index) {
              if (index == 0) {
                return new Container(
                  margin: new EdgeInsets.only(bottom: 16.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Flexible(
                        child: new Container(
                          child: new RaisedButton(
                            color: Colors.white,
                            child: new Column(
                              children: <Widget>[
                                new Icon(
                                  Icons.add,
                                  color: Theme.of(context).primaryColor,
                                  size: 48.0,
                                ),
                                new Text(
                                  "Tambahkan Pengingat Harian",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14.0,
                                  ),
                                )
                              ],
                            ),
                            onPressed: () {
                              Navigator
                                  .of(context)
                                  .push<Pasien>(new MaterialPageRoute(
                                    builder: (_) =>
                                        new ApotekerInputDailyAlarmScreen(),
                                  ))
                                  .then((Pasien selectedPasien) {
                                if (selectedPasien != null) {
                                  Scaffold.of(context).showSnackBar(new SnackBar(
                                      content: new Text(
                                          "Alarm untuk pasien ${selectedPasien.displayName} berhasil ditambahkan")));
                                }
                              });
                            },
                            padding: new EdgeInsets.symmetric(vertical: 8.0),
                          ),
                          margin: new EdgeInsets.only(right: 8.0),
                        ),
                      ),
                      new Flexible(
                        child: new Container(
                          child: new RaisedButton(
                            color: Colors.white,
                            child: new Column(
                              children: <Widget>[
                                new Icon(
                                  Icons.add,
                                  color: Theme.of(context).primaryColor,
                                  size: 48.0,
                                ),
                                new Text(
                                  "Tambahkan Pengingat Kustom",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14.0,
                                  ),
                                )
                              ],
                            ),
                            onPressed: () {
                              Navigator
                                  .of(context)
                                  .push<Pasien>(new MaterialPageRoute(
                                builder: (_) =>
                                new ApotekerInputCustomAlarmScreen(),
                              ))
                                  .then((Pasien selectedPasien) {
                                if (selectedPasien != null) {
                                  Scaffold.of(context).showSnackBar(new SnackBar(
                                      content: new Text(
                                          "Alarm untuk pasien ${selectedPasien.displayName} berhasil ditambahkan")));
                                }
                              });
                            },
                            padding: new EdgeInsets.symmetric(vertical: 8.0),
                          ),
                          margin: new EdgeInsets.only(right: 8.0),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (dataCount == 0) {
                return new Center(
                    child: new Text("Belum ada Pasien yang terverifikasi."));
              }
              final pasien = data[index - 1];
              return new UserCard(
                user: pasien,
                onTap: () {
                  Navigator.of(context).push(new MaterialPageRoute(
                    builder: (_) => new PasienStatisticScreen(pasien: pasien,),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
