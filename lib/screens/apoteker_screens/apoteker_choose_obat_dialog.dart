import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:tuberculos/models/obat.dart';
import "package:tuberculos/services/api.dart";
import 'package:tuberculos/widgets/full_width_widget.dart';

class ApotekerChooseObatDialog extends StatelessWidget {
  final CollectionReference obatCollectionReference;

  ApotekerChooseObatDialog(this.obatCollectionReference);

  Widget _buildStreams() {
    return new StreamBuilder<QuerySnapshot>(
        stream: (obatCollectionReference ?? getObatCollectionReference())
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return new Center(child: new Text('Loading...'));
          }
          final List<Obat> data = snapshot.data.documents
              .map((DocumentSnapshot documentSnapshot) =>
                  new Obat.fromJson(documentSnapshot.data))
              .toList();
          final int dataCount = data.length;
          if (dataCount > 0) {
            return new ListView.builder(
              itemCount: dataCount,
              itemBuilder: (_, int index) {
                final Obat obat = data[index];
                return new ListTile(
                    trailing: new CircleAvatar(
                      backgroundImage: obat.photoUrl != null
                          ? new NetworkImage(obat.photoUrl)
                          : null,
                    ),
                    subtitle:
                        new Text(obat.description ?? '<No message retrieved>'),
                    title: new Text(obat.name),
                    onTap: () {
                      Navigator.pop(context, obat);
                    });
              },
            );
          }
          return new Center(
            child: new Container(
              child: new Text(
                "Belum ada obat yang terdaftar dalam sistem.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Dialog(
      child: new Column(
        children: <Widget>[
          new Expanded(child: _buildStreams()),
          new Container(
            alignment: Alignment.bottomCenter,
            child: new FullWidthWidget(
                child: new RaisedButton(
              color: Theme.of(context).primaryColorDark,
              child: new Text("Tambah Obat Baru"),
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                      builder: (_) => new ApotekerCreateObatScreen(),
                    ));
              },
            )),
          ),
        ],
      ),
    );
  }
}

class ApotekerCreateObatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ApotekerCreateObatScreenState();
}

class _ApotekerCreateObatScreenState extends State<ApotekerCreateObatScreen> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text(
        "Tambah Obat Baru",
        style: new TextStyle(letterSpacing: 1.0),
      )),
      body: new Container(
        margin: new EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        child: new Form(
          child: new Column(
            children: <Widget>[
              new Container(
                  child: new Column(
                children: <Widget>[
                  new Text("Nama Obat",
                      style: new TextStyle(
                        color: Theme.of(context).primaryColorDark,
                      )),
                  new TextFormField(
                    decoration: new InputDecoration(hintText: "Nama Obat"),
                    validator: (String s) {
                      if (s.isEmpty) return "Nama Obat tidak boleh kosong.";
                    },
                  ),
                ],
              )),
              new Container(
                  child: new Column(children: <Widget>[
                new Text("Deskripsi Obat",
                    style: new TextStyle(
                        color: Theme.of(context).primaryColorDark)),
                new TextFormField(
                  decoration: new InputDecoration(
                    hintText: "Deskripsi Obat",
                  ),
                  validator: (String s) {
                    if (s.isEmpty) return "Deskripsi Obat tidak boleh kosong.";
                  },
                ),
              ])),
              new Container(
                child: new Column(
                  children: <Widget>[],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
