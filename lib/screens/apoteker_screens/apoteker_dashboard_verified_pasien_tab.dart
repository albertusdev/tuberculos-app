
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/services/api.dart';
import 'package:tuberculos/widgets/full_width_widget.dart';
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
                return new FullWidthWidget(
                    child: new MaterialButton(
                      child: new Container(
                        child: new Column(
                          children: <Widget>[
                            new Icon(
                              Icons.add,
                              size: 48.0,
//                          color: Theme.of(context).primaryColor,
                            ),
                            new Text(
                              "Tambahkan Pengingat",
                              style: new TextStyle(
//                            color: Theme.of(context).primaryColor,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                        margin: new EdgeInsets.symmetric(vertical: 16.0),
                        padding: new EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      onPressed: () {},
                    ));
              }
              final pasien = data[index - 1];
              return new UserCard(
                user: pasien,
                onTap: () {
                  Scaffold.of(context).showSnackBar(
                      new SnackBar(content: new Text(pasien.email)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
