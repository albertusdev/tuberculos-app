import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/screens/string_input_screen.dart';
import "package:tuberculos/services/api.dart";
import 'package:tuberculos/widgets/full_width_widget.dart';

class ApotekerChooseObatDialog extends StatelessWidget {
  final CollectionReference obatCollectionReference;

  ApotekerChooseObatDialog(this.obatCollectionReference);

  Widget _buildStreams() {
    return new StreamBuilder<QuerySnapshot>(
        stream: (obatCollectionReference ?? getObatCollectionReference())
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return new Center(child: new Text('Loading...'));
          }
          final List<Obat> data = snapshot.data.documents
              .map((DocumentSnapshot documentSnapshot) =>
                  new Obat.fromJson(documentSnapshot.data))
              .toList();
          final int dataCount = data.length;
          if (dataCount > 0) {
            return new ListView.builder(
              itemCount: dataCount,
              itemBuilder: (_, int index) {
                final Obat obat = data[index];
                return new ListTile(
                    trailing: new CircleAvatar(
                      backgroundImage: obat.photoUrl != null
                          ? new NetworkImage(obat.photoUrl)
                          : null,
                    ),
                    subtitle:
                        new Text(obat.description ?? '<No message retrieved>'),
                    title: new Text(obat.name),
                    onTap: () {
                      Navigator.pop(context, obat);
                    });
              },
            );
          }
          return new Center(
            child: new Container(
              child: new Text(
                "Belum ada obat yang terdaftar dalam sistem.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.title,
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new Dialog(
      child: new Column(
        children: <Widget>[
          new Expanded(child: _buildStreams()),
          new Container(
            alignment: Alignment.bottomCenter,
            child: new FullWidthWidget(
                child: new RaisedButton(
              color: Theme.of(context).primaryColorDark,
              child: new Text("Tambah Obat Baru"),
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                      builder: (_) => new ApotekerCreateObatScreen(),
                    ));
              },
            )),
          ),
        ],
      ),
    );
  }
}

class ApotekerCreateObatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ApotekerCreateObatScreenState();
}

class _ApotekerCreateObatScreenState extends State<ApotekerCreateObatScreen> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  bool isLoading = false;
  Obat obat = new Obat();
  File imageFile = null;

  _handleSubmit(BuildContext context) async {
    try {
      if (obat.name == null || obat.description == null || imageFile == null) {
        throw "Form tidak boleh kosong";
      }
      setState(() => isLoading = true);
      obat.photoUrl = await uploadFile(imageFile);
      await createNewObat(obat);
      setState(() => isLoading = false);
      Navigator.pop(context);
    } catch (e) {
      Scaffold
          .of(context)
          .showSnackBar(new SnackBar(content: new Text(e.toString())));
    }
  }

  Widget _createBottomNavigationBarWidget(BuildContext context) {
    List<Widget> bottomNavigationBarChildren = [];
    if (isLoading)
      bottomNavigationBarChildren.add(new LinearProgressIndicator());
    bottomNavigationBarChildren.add(new FullWidthWidget(
      child: new RaisedButton(
        color: Theme.of(context).primaryColor,
        child: new Text(
          "Tambah Obat",
          style: new TextStyle(color: Colors.white),
        ),
        onPressed: () => _handleSubmit(context),
      ),
    ));
    return new Column(
      children: bottomNavigationBarChildren,
      mainAxisSize: MainAxisSize.min,
    );
  }

  _pickImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      print(imageFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text(
        "Tambah Obat Baru",
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
                      child: imageFile == null
                          ? new Center(
                              child: new RaisedButton(
                              child: new Text("Tambahkan Foto"),
                              onPressed: _pickImage,
                            ))
                          : new InkWell(
                              child: new Image.file(imageFile,
                                  fit: BoxFit.fitHeight),
                              onTap: _pickImage),
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
                                        obat.name == null
                                            ? new Text(
                                                "Masukkan Nama Obat",
                                                style: new TextStyle(
                                                  color: Theme
                                                      .of(context)
                                                      .disabledColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : new Text(
                                                obat.name,
                                                style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ]),
                                  onPressed: () {
                                    Navigator
                                        .of(context)
                                        .push<String>(
                                          new MaterialPageRoute(
                                            builder: (_) =>
                                                new StringInputScreen(
                                                  title: "Nama Obat",
                                                  hintText:
                                                      "Masukkan Nama Obat",
                                                ),
                                          ),
                                        )
                                        .then((String name) {
                                          obat.name = name;
                                    });
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
                                        obat.description == null
                                            ? new Text(
                                                "Masukkan Deskripsi Obat",
                                                style: new TextStyle(
                                                  color: Theme
                                                      .of(context)
                                                      .disabledColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : new Text(
                                                obat.description,
                                                style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ]),
                                  onPressed: () {
                                    Navigator
                                        .of(context)
                                        .push<String>(new MaterialPageRoute(
                                          builder: (_) => new StringInputScreen(
                                              title: "Deskripsi Obat",
                                              hintText:
                                                  "Masukkan Deskripsi Obat"),
                                        ))
                                        .then((String description) {
                                          obat.description = description;
                                    });
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
      bottomNavigationBar: new Builder(
          builder: (BuildContext context) =>
              _createBottomNavigationBarWidget(context)),
    );
  }
}
