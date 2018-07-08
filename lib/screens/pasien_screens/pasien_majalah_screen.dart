import "package:android_intent/android_intent.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:tuberculos/models/majalah.dart';
import "package:tuberculos/services/api.dart";

class MajalahCard extends StatelessWidget {
  final Majalah majalah;

  MajalahCard({Key key, this.majalah}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: new EdgeInsets.symmetric(vertical: 8.0),
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
          title: new Text(majalah.title),
          subtitle: new Column(
            children: <Widget>[
              new Text(majalah.description),
              new Container(
                margin: new EdgeInsets.only(top: 8.0),
                child: new Text(
                    "${new DateFormat("yMMMd").format(majalah.dateTimeCreated)} - ${new DateFormat.Hms().format(majalah.dateTimeCreated)}",
                    style: new TextStyle(
                      color: Theme.of(context).disabledColor,
                      fontSize: 12.0,
                    )),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          trailing: new CircleAvatar(
            backgroundImage: new NetworkImage(majalah.creator.photoUrl),
          ),
          onTap: () {
            AndroidIntent intent = new AndroidIntent(
              action: 'action_view',
              data: majalah.downloadUrl,
            );
            intent.launch();
          },
        ));
  }
}

class PasienMajalahScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Expanded(
              child: new StreamBuilder(
                  stream: getMajalahCollectionReference().snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return new Center(
                        child: new CircularProgressIndicator(),
                      );
                    }
                    final data = snapshot.data.documents
                        .map((ds) => new Majalah.fromJson(ds.data))
                        .toList();
                    return new ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) =>
                          new MajalahCard(majalah: data[index]),
                    );
                  }))
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      margin: new EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
    );
  }
}
