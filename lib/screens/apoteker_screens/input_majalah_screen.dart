import 'dart:io';

import "package:android_intent/android_intent.dart";
import 'package:flutter/material.dart';
import 'package:tuberculos/screens/input_screen.dart';
import 'package:tuberculos/widgets/full_width_widget.dart';

class InputMajalahScreen extends StatefulWidget {
  @override
  _InputMajalahScreenState createState() => _InputMajalahScreenState();
}

class _InputMajalahScreenState extends State<InputMajalahScreen> {
  String _title;
  String _description;
  File file;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    child: new Text(
                      "Judul Majalah",
                      style: new TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    margin: new EdgeInsets.only(bottom: 8.0),
                  ),
                  new FullWidthWidget(
                    child: new OutlineButton(
                      child: new Text(
                        _title == null ? "Masukkan judul majalah" : _title,
                        style: new TextStyle(
                          color: _title == null
                              ? Theme.of(context).disabledColor
                              : Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      onPressed: () {
                        Navigator
                            .of(context)
                            .push<String>(new MaterialPageRoute(
                                builder: (_) => new StringInputScreen(
                                      title: "Judul Majalah",
                                      hintText: "Masukkan judul majalah",
                                    )))
                            .then((String title) {
                          setState(() => this._title = title);
                        });
                      },
                    ),
                  )
                ],
              ),
              margin: new EdgeInsets.only(top: 16.0),
            ),
            new Container(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      child: new Text(
                        "Deskripsi Majalah",
                        style: new TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      margin: new EdgeInsets.only(bottom: 8.0),
                    ),
                    new FullWidthWidget(
                      child: new OutlineButton(
                        child: new Text(
                          _description == null
                              ? "Masukkan deskripsi majalah"
                              : _description,
                          style: new TextStyle(
                            color: _description == null
                                ? Theme.of(context).disabledColor
                                : Colors.black,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        onPressed: () {
                          Navigator
                              .of(context)
                              .push<String>(new MaterialPageRoute(
                                  builder: (_) => new StringInputScreen(
                                        title: "Deskripsi Majalah",
                                        hintText: "Masukkan deskripsi majalah",
                                      )))
                              .then((String description) {
                            setState(() => this._description = description);
                          });
                        },
                      ),
                    )
                  ],
                ),
                margin: new EdgeInsets.symmetric(
                  vertical: 16.0,
                )),
            new OutlineButton(
              child: new Text("Pilih file"),
              onPressed: () {
                AndroidIntent intent = new AndroidIntent(
                  action: 'action_view',
                  data:
                      'https://firebasestorage.googleapis.com/v0/b/tuberculos-e576c.appspot.com/o/166259_PKM%20KC_Anja%20Tamabri%20copy.pdf?alt=media&token=58161459-e23d-4ee8-8125-ad6df1c6de21',
                );
                intent.launch();
              },
            )
          ]),
    );
  }
}
