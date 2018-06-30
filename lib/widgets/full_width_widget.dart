import 'package:flutter/material.dart';

class FullWidthWidget extends StatelessWidget {
  Widget child;

  FullWidthWidget({this.child});

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: child,
        ),
      ],
    );
  }
}
