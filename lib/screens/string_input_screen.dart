import "package:flutter/material.dart";
import 'package:tuberculos/widgets/full_width_widget.dart';

class StringInputScreen extends StatefulWidget {
  final String title;
  final String hintText;

  StringInputScreen({Key key, this.title, this.hintText}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _StringInputScreenState(title, hintText);
}

class _StringInputScreenState extends State<StringInputScreen> {
  final String title;
  final String hintText;

  final TextEditingController controller = new TextEditingController();

  _StringInputScreenState(this.title, this.hintText);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(title)),
        body: new Container(
          child: new Column(
            children: <Widget>[
              new TextFormField(
                controller: controller,
                decoration: new InputDecoration(
                  hintText: hintText,
                ),
              ),
              new Container(
                child: new FullWidthWidget(
                  child: new RaisedButton(
                    child: new Text(
                      "Simpan",
                      style: new TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.of(context).pop(controller.text);
                    },
                  ),
                ),
                margin: new EdgeInsets.only(top: 16.0),
              ),
            ],
          ),
          margin: new EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ));
  }
}
