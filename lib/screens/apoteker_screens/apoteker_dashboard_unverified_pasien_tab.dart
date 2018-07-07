import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/services/api.dart';
import 'package:tuberculos/widgets/user_card.dart';
import 'package:tuberculos/widgets/verify_pasien_dialog.dart';

class UnverifiedPasiensTab extends StatefulWidget {
  final Apoteker apoteker;

  UnverifiedPasiensTab({Key key, this.apoteker});

  @override
  State<StatefulWidget> createState() => new _UnverifiedPasiensTab(apoteker);
}

class _UnverifiedPasiensTab extends State<UnverifiedPasiensTab> {
  Apoteker apoteker;

  _UnverifiedPasiensTab(this.apoteker);

  void _showVerifyPasienDialog({BuildContext context, Pasien pasien}) {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) =>
      new VerifyPasienDialog(pasien: pasien),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            ..removeWhere((pasien) => pasien.isVerified);
          final int dataCount = data.length;
          if (dataCount > 0) {
            child = new ListView.builder(
              itemCount: dataCount,
              itemBuilder: (_, int index) {
                final pasien = data[index];
                return new UserCard(
                  user: pasien,
                  onTap: () {
                    _showVerifyPasienDialog(context: context, pasien: pasien);
                  },
                );
              },
            );
          } else {
            child = new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text("Tidak ada pasien yang belum terverifikasi."),
                ],
              ),
            );
          }
          return child;
        },
      ),
    );
  }
}
