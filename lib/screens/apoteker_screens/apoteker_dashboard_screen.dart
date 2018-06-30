import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/services/api.dart';
import 'package:tuberculos/widgets/full_width_widget.dart';

class ApotekerDashboardScreen extends StatefulWidget {
  final Apoteker apoteker;

  ApotekerDashboardScreen({Key key, this.apoteker}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _ApotekerDashboardScreenState(apoteker);
}

class _ApotekerDashboardScreenState extends State<ApotekerDashboardScreen>
    with SingleTickerProviderStateMixin {
  final Apoteker apoteker;

  _ApotekerDashboardScreenState(this.apoteker);

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
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
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
      if (pasien.displayName != null) {
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
              return new ListTileTheme(
                child: new ListTile(
                  leading: new CircleAvatar(
                    backgroundImage: pasien.photoUrl != null
                        ? new NetworkImage(pasien.photoUrl)
                        : null,
                    child: _getCircleAvatarChild(pasien),
                  ),
                  subtitle: new Text(pasien.email ?? '<No message retrieved>'),
                  title: new Text(pasien.displayName),
                  onTap: () {
                    Scaffold.of(context).showSnackBar(
                        new SnackBar(content: new Text(pasien.email)));
                  },
                ),
              );
            },
          );
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
      if (pasien.displayName != null) {
        return new Text(pasien.displayName);
      } else {
        return new Text("...");
      }
    }
    return null;
  }

  void _showVerifyPasienDialog({BuildContext context, Pasien pasien}) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          new _VerifyPasienDialog(pasien: pasien),
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
                return new Container(
                  child: new ListTile(
                    trailing: new CircleAvatar(
                      backgroundImage: pasien.photoUrl != null
                          ? new NetworkImage(pasien.photoUrl)
                          : null,
                      child: _getCircleAvatarChild(pasien),
                    ),
                    subtitle:
                        new Text(pasien.email ?? '<No message retrieved>'),
                    title: new Text(pasien.displayName),
                    onTap: () {
                      _showVerifyPasienDialog(context: context, pasien: pasien);
                    },
                  ),
                  decoration: new BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: <BoxShadow>[
                      new BoxShadow(
                        color: Theme.of(context).disabledColor,
                      )
                    ],
                  ),
                  margin:
                      new EdgeInsets.only(bottom: 2.0, left: 2.0, right: 2.0),
                  padding: new EdgeInsets.symmetric(vertical: 8.0),
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

class _VerifyPasienDialog extends StatefulWidget {
  final Pasien pasien;

  _VerifyPasienDialog({Key key, this.pasien}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _VerifyPasienDialogState(this.pasien);
}

class _VerifyPasienDialogState extends State<_VerifyPasienDialog> {
  final Pasien pasien;
  int tuberculosStage;
  bool isLoading = false;

  _VerifyPasienDialogState(this.pasien);

  @override
  Widget build(BuildContext context) {
    return new Dialog(
      child: new Container(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Flexible(
                    flex: 4,
                    child: new Text(
                      "Pasien ini membutuhkan Verifikasi",
                      style: new TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    )),
                new Flexible(
                    flex: 1,
                    child: new Container(
                      child: new Container(
                        child: new Text(""),
                        color: Theme.of(context).primaryColor,
                        margin: new EdgeInsets.all(4.0),
                        padding: new EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(6.0)),
                        border: new Border.all(
                            color: Theme.of(context).primaryColor),
                      ),
                    )),
              ],
            ),
            new Container(
              margin: new EdgeInsets.symmetric(vertical: 32.0),
              child: new DropdownButton<int>(
                hint: new Text("Pilih Stadium"),
                items: [
                  new DropdownMenuItem(child: new Text("Fase Awal"), value: 0),
                  new DropdownMenuItem(
                      child: new Text("Fase Lanjutan"), value: 1),
                ],
                elevation: 1,
                value: tuberculosStage,
                onChanged: (int newValue) {
                  setState(() {
                    tuberculosStage = newValue;
                  });
                },
              ),
            ),
            new FullWidthWidget(
              child: new MaterialButton(
                child: isLoading
                    ? new SizedBox(
                        child: new CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                        width: 16.0,
                        height: 16.0,
                      )
                    : new Text(
                        "KONFIRMASI",
                        style: new TextStyle(
                          color: Colors.white,
                        ),
                      ),
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await verifyPasien(pasien.email, tuberculosStage);
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.of(context).pop(pasien.email);
                },
                padding: new EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ],
        ),
        margin: new EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      ),
    );
  }
}
