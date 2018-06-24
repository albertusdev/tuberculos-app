import "package:flutter/material.dart";

class ContinueWithGoogleButton extends StatelessWidget {
  VoidCallback onPressed;

  ContinueWithGoogleButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new OutlineButton(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 8.0),
                  child: new Image(
                    image: new AssetImage("assets/pictures/google-logo.png"),
                    width: 16.0,
                  ),
                ),
                new Text("Lanjut dengan Google"),
              ],
            ),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}