import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/utils.dart';

class ChoosePasienDialog extends StatelessWidget {
  final CollectionReference userCollectionReference;

  ChoosePasienDialog(this.userCollectionReference);

  Widget _getCircleAvatarChild(User user) {
    if (user.photoUrl == null) {
      if (user.displayName != null) {
        return new Text(getInitialsOfDisplayName(user.displayName));
      } else {
        return new Text("...");
      }
    }
    return null;
  }

  Widget _buildStreams() {
    return new StreamBuilder<QuerySnapshot>(
        stream: userCollectionReference.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          Widget child;
          if (!snapshot.hasData) {
            return new Center(child: new Text('Loading...'));
          }
          final data = snapshot.data.documents
              .map((DocumentSnapshot documentSnapshot) =>
                  new User.createSpecificUserFromJson(documentSnapshot.data))
              .toList();
          final int dataCount = data.length;
          if (dataCount > 0) {
            return new ListView.builder(
              itemCount: dataCount,
              itemBuilder: (_, int index) {
                final User user = data[index];
                return new ListTile(
                    trailing: new CircleAvatar(
                      backgroundImage: user.photoUrl != null
                          ? new NetworkImage(user.photoUrl)
                          : null,
                      child: _getCircleAvatarChild(user),
                    ),
                    subtitle: new Text(user.email ?? '<No message retrieved>'),
                    title: new Text(user.displayName),
                    onTap: () {
                      Navigator.pop(context, user.email);
                    });
              },
            );
          }
          return new Center(
            child: new Text(
              "Maaf, anda belum memiliki Pasien yang sudah terverifikasi.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.title,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Dialog(
      child: _buildStreams(),
    );
  }
}
