
import 'package:flutter/material.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/widgets/full_width_widget.dart';

class ShowObatScreen extends StatelessWidget {

  final Obat obat;

  ShowObatScreen(this.obat);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text(
            obat.name,
            style: new TextStyle(letterSpacing: 1.0),
          )),
      body: new Builder(
        builder: (context) => new Container(
          margin: new EdgeInsets.only(left: 24.0, right: 24.0),
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: new Container(
                  alignment: Alignment.center,
                  child: new Image.network(obat.photoUrl, fit: BoxFit.cover),
                  margin: new EdgeInsets.only(top: 8.0),
                ),
                fit: FlexFit.tight,
              ),
              new Flexible(
                fit: FlexFit.tight,
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Container(
                            alignment: Alignment.topLeft,
                            child: new Text(
                              "Nama Obat",
                              style: new TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            margin: new EdgeInsets.only(bottom: 4.0),
                          ),
                          new FullWidthWidget(
                            child: new OutlineButton(
                              child: new Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      obat.name,
                                      style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]),
                              onPressed: () {
                              },
                            ),
                          ),
                        ],
                      ),
                      margin: new EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    new Container(
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            alignment: Alignment.topLeft,
                            child: new Text(
                              "Deskripsi Obat",
                              style: new TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            margin: new EdgeInsets.only(bottom: 4.0),
                          ),
                          new FullWidthWidget(
                            child: new OutlineButton(
                              child: new Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    new Text(
                                      obat.description,
                                      style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]),
                              onPressed: () {
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}