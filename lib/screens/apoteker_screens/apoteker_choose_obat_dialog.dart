import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/screens/apoteker_screens/apoteker_create_obat_screen.dart';
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
              child: new Text("Tambah Obat Baru", style: new TextStyle(color: Colors.white)),
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

