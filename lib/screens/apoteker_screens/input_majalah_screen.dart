import 'dart:io';

import "package:documents_picker/documents_picker.dart";
import 'package:flutter/material.dart';
import 'package:tuberculos/screens/input_screen.dart';
import 'package:tuberculos/widgets/full_width_widget.dart';

class InputMajalahScreen extends StatefulWidget {
  @override
  _InputMajalahScreenState createState() => _InputMajalahScreenState();
}

class _InputMajalahScreenState extends State<InputMajalahScreen> {
  bool _isLoading = false;
  String _title;
  String _description;
  File _file;

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
                          if (title != null && title.isNotEmpty)
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
                            if (description != null && description.isNotEmpty)
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
            new Container(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    child: new Text(
                      "File PDF Majalah",
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
                        _file == null
                            ? "Pilih majalah"
                            : _file.path.split("/").last,
                        style: new TextStyle(
                          color: _file == null
                              ? Theme.of(context).disabledColor
                              : Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      onPressed: () async {
                        List<dynamic> filePaths =
                            await DocumentsPicker.pickDocuments;
                        print(filePaths.first);
                        setState(() {
                          _file = new File(filePaths.first);
                        });
                      },
                    ),
                  )
                ],
              ),
              margin: new EdgeInsets.symmetric(
                vertical: 16.0,
              ),
            ),
            new FullWidthWidget(
              child: new RaisedButton(
                child: !_isLoading
                    ? new Text("Upload",
                        style: new TextStyle(
                          color: Colors.white,
                        ))
                    : new SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: new CircularProgressIndicator()),
                color: Theme.of(context).primaryColor,
                onPressed: () {},
              ),
            )
          ]),
    );
  }
}
