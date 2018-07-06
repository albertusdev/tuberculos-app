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

class NumberInputScreen extends StatefulWidget {
  final String title;
  final String hintText;

  NumberInputScreen({Key key, this.title, this.hintText}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _NumberInputScreenState(title, hintText);
}

class _NumberInputScreenState extends State<NumberInputScreen> {
  final String title;
  final String hintText;

  final TextEditingController controller = new TextEditingController();

  _NumberInputScreenState(this.title, this.hintText);

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
                keyboardType: TextInputType.number,
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

class MultiLineInputScreen extends StatefulWidget {
  final String title;
  final String hintText;

  MultiLineInputScreen({Key key, this.title, this.hintText}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _MultiLineInputScreenState(title, hintText);
}

class _MultiLineInputScreenState extends State<MultiLineInputScreen> {
  final String title;
  final String hintText;

  final TextEditingController controller = new TextEditingController();

  _MultiLineInputScreenState(this.title, this.hintText);

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
                keyboardType: TextInputType.multiline,
                maxLines: 5,
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