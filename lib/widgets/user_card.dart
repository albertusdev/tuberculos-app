import 'package:flutter/material.dart';
import 'package:tuberculos/models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final onTap;

  UserCard({Key key, this.user, this.onTap}) : super(key: key);

  Widget _getCircleAvatarChild(User user) {
    if (user.photoUrl == null) {
      if (user.displayName != null) {
        return new Text(user.displayName);
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
          backgroundImage: user.photoUrl != null
              ? new NetworkImage(user.photoUrl)
              : null,
          child: _getCircleAvatarChild(user),
        ),
        subtitle: new Text(user.email ?? '<No message retrieved>'),
        title: new Text(user.displayName),
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
