import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/services/api.dart';

class ApotekerDashboardScreen extends StatefulWidget {
  final Apoteker apoteker;

  ApotekerDashboardScreen({Key key, this.apoteker}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _ApotekerDashboardScreenState(apoteker);
}

class _ApotekerDashboardScreenState extends State<ApotekerDashboardScreen>
    with SingleTickerProviderStateMixin {
  Apoteker apoteker;
  TabController tabController;

  _ApotekerDashboardScreenState(Apoteker apoteker) {
    this.apoteker = apoteker;
    this.tabController = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Column(
        children: [
          new Row(
            children: [
              new Expanded(
                child: new Container(
                  child: new TabBar(
                    tabs: [
                      new Container(
                        padding: new EdgeInsets.all(16.0),
                        child: new Text(
                          "Terverifikasi",
                        ),
                      ),
                      new Container(
                        child: new Text(
                          "Belum Terverifikasi",
                        ),
                        padding: new EdgeInsets.all(16.0),
                      ),
                    ],
                    indicatorColor: Theme.of(context).accentColor,
                    labelColor: Theme.of(context).accentColor,
                    unselectedLabelColor: Theme.of(context).highlightColor,
                  ),
                ),
              )
            ],
          ),
          new Expanded(
            child: new TabBarView(
              children: [
                new VerifiedPasiensTab(apoteker: apoteker),
                new UnverifiedPasiensTab(apoteker: apoteker),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerifiedPasiensTab extends StatefulWidget {

  final Apoteker apoteker;

  VerifiedPasiensTab({Key key, this.apoteker});

  @override
  State<StatefulWidget> createState() => new _VerifiedPasienTabState(apoteker);
}

class _VerifiedPasienTabState extends State<VerifiedPasiensTab> {
  Apoteker apoteker;

  _VerifiedPasienTabState(this.apoteker);

  Widget _getCircleAvatarChild(Pasien pasien) {
    if (pasien.photoUrl == null) {
      if (pasien.displayName!= null) {
        return new Text(pasien.displayName);
      } else {
        return new Text("...");
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.all(8.0),
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
          new Pasien.fromJson(document.data))
              .toList()..retainWhere((pasien) => pasien.isVerified);
          final int dataCount = data.length;
          if (dataCount > 0) {
            child = new ListView.builder(
              itemCount: dataCount,
              itemBuilder: (_, int index) {
                final pasien = data[index];
                return new ListTile(
                    leading: new CircleAvatar(
                      backgroundImage: pasien.photoUrl != null
                          ? new NetworkImage(pasien.photoUrl)
                          : null,
                      child: _getCircleAvatarChild(pasien),
                    ),
                    subtitle:
                    new Text(pasien.email ?? '<No message retrieved>'),
                    title: new Text(pasien.displayName),
                    onTap: () {
                      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(pasien.email)));
                    });
              },
            );
          } else {
            child = new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text("Tidak ada pasien yang sudah terverifikasi."),
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

class UnverifiedPasiensTab extends StatefulWidget {
  final Apoteker apoteker;

  UnverifiedPasiensTab({Key key, this.apoteker});

  @override
  State<StatefulWidget> createState() => new _UnverifiedPasiensTab(apoteker);
}

class _UnverifiedPasiensTab extends State<UnverifiedPasiensTab> {
  Apoteker apoteker;

  _UnverifiedPasiensTab(this.apoteker);

  Widget _getCircleAvatarChild(Pasien pasien) {
    if (pasien.photoUrl == null) {
      if (pasien.displayName!= null) {
        return new Text(pasien.displayName);
      } else {
        return new Text("...");
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.all(8.0),
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
          new Pasien.fromJson(document.data))
              .toList()..removeWhere((pasien) => pasien.isVerified);
          final int dataCount = data.length;
          if (dataCount > 0) {
            child = new ListView.builder(
              itemCount: dataCount,
              itemBuilder: (_, int index) {
                final pasien = data[index];
                return new ListTile(
                    leading: new CircleAvatar(
                      backgroundImage: pasien.photoUrl != null
                          ? new NetworkImage(pasien.photoUrl)
                          : null,
                      child: _getCircleAvatarChild(pasien),
                    ),
                    subtitle:
                    new Text(pasien.email ?? '<No message retrieved>'),
                    title: new Text(pasien.displayName),
                    onTap: () {
                      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(pasien.email)));
                    });
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
