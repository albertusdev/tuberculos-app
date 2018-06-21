import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class ChooseApotekerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return new Dialog(child: const Text('Loading...'));
        }
        final int dataCount = snapshot.data.documents.length;
        return new Dialog(
          child: new ListView.builder(
            itemCount: dataCount,
            itemBuilder: (_, int index) {
              final DocumentSnapshot document = snapshot.data.documents[index];
              return new ListTile(
                  title:
                      new Text(document['email'] ?? '<No message retrieved>'),
                  subtitle: new Text(
                      '${document['firstName']} ${document['lastName']}'),
                  onTap: () {
                    Navigator.pop(context, document["email"]);
                  });
            },
          ),
        );
      },
    );
  }
}
