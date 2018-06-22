import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "package:tuberculos/utils.dart";

class ChooseApotekerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;
        if (!snapshot.hasData) {
          child = const Text('Loading...');
        }
        final filteredData =
            snapshot.data.documents.where((DocumentSnapshot document) {
          print(document.data);
          return document.data["role"] == UserRole.apoteker.toString();
        }).toList();
        final int dataCount = filteredData.length;
        if (dataCount > 0) {
          child = new ListView.builder(
            itemCount: dataCount,
            itemBuilder: (_, int index) {
              final DocumentSnapshot document = filteredData[index];
              return new ListTile(
                  title:
                      new Text(document['email'] ?? '<No message retrieved>'),
                  subtitle: new Text(
                      '${document['firstName']} ${document['lastName']}'),
                  onTap: () {
                    Navigator.pop(context, document["email"]);
                  });
            },
          );
        } else {
          child = new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text("Maaf, belum ada Apoteker yang terdaftar dalam sistem."),
                ],
              ),
          );
        }
        return new Dialog(
          child: child,
        );
      },
    );
  }
}
