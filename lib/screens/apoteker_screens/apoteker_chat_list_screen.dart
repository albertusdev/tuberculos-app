import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/screens/chat_screen.dart';
import "package:tuberculos/services/api.dart";
import 'package:tuberculos/widgets/user_card.dart';

class ApotekerChatListScreen extends StatefulWidget {
  final Apoteker apoteker;

  ApotekerChatListScreen({Key key, this.apoteker}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _ApotekerChatListScreenState(apoteker);
}

class _ApotekerChatListScreenState extends State<ApotekerChatListScreen> {
  final Apoteker apoteker;

  _ApotekerChatListScreenState(this.apoteker);

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
        stream: getPasiensCollectionReference(apoteker?.email)?.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          Widget child;
          if (!snapshot.hasData) {
            return new Center(
              child: new CircularProgressIndicator(),
            );
          }
          final List<Pasien> data = snapshot.data.documents
              .map((DocumentSnapshot document) =>
                  new Pasien.fromJson(document.data))
              .toList();
          final int dataCount = data.length;
          if (dataCount > 0) {
            child = new ListView.builder(
              itemCount: dataCount,
              itemBuilder: (_, int index) {
                final pasien = data[index];
                return new UserCard(
                    user: pasien,
                    onTap: () {
                      Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) => new ChatScreen(
                                documentRef: getMessageCollectionReference(
                                    pasien.chatId)),
                          ));
                    });
              },
            );
          } else {
            child = new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text("Anda belum memiliki Pasien."),
                ],
              ),
            );
          }
          return new Container(
              margin: new EdgeInsets.all(16.0),
              child: child
          );
        });
  }
}
