import 'package:flutter/material.dart';
import 'package:tuberculos/models/pasien.dart';

class PasienCard extends StatelessWidget {
  final Pasien pasien;
  final onTap;

  PasienCard({Key key, this.pasien, this.onTap}) : super(key: key);

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
      child: new ListTile(
        trailing: new CircleAvatar(
          backgroundImage: pasien.photoUrl != null
              ? new NetworkImage(pasien.photoUrl)
              : null,
          child: _getCircleAvatarChild(pasien),
        ),
        subtitle: new Text(pasien.email ?? '<No message retrieved>'),
        title: new Text(pasien.displayName),
        onTap: onTap,
      ),
      decoration: new BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Theme.of(context).disabledColor,
          )
        ],
      ),
      margin: new EdgeInsets.only(bottom: 2.0, left: 2.0, right: 2.0),
      padding: new EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}
