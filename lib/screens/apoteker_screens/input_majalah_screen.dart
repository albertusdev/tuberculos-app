import 'dart:io';

import "package:android_intent/android_intent.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:documents_picker/documents_picker.dart";
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import "package:intl/intl.dart";
import "package:simple_permissions/simple_permissions.dart";
import 'package:tuberculos/models/majalah.dart';
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/redux/configure_store.dart';
import 'package:tuberculos/screens/input_screen.dart';
import 'package:tuberculos/services/api.dart';
import 'package:tuberculos/widgets/full_width_widget.dart';

class ConfirmDeleteDialog extends StatefulWidget {
  final Majalah majalah;

  ConfirmDeleteDialog(this.majalah);

  @override
  _ConfirmDeleteDialogState createState() => _ConfirmDeleteDialogState(majalah);
}

class _ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {
  final Majalah majalah;

  bool isLoading = false;

  _ConfirmDeleteDialogState(this.majalah);

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text("Apakah anda yakin ingin menghapus majalah ini?"),
      actions: <Widget>[
        new FlatButton(
          child: !isLoading
              ? new Text(
                  "Ya",
                  style: new TextStyle(
                    color: Colors.red,
                  ),
                )
              : new SizedBox(
                  child: new CircularProgressIndicator(),
                  width: 16.0,
                  height: 16.0,
                ),
          onPressed: isLoading
              ? null
              : () async {
                  setState(() => isLoading = true);
                  await getMajalahDocumentReference(majalah.id).delete();
                  Navigator.of(context).pop(true);
                },
        ),
        new FlatButton(
          child: !isLoading
              ? new Text(
                  "Tidak",
                  style: new TextStyle(
                    color: Colors.green,
                  ),
                )
              : new SizedBox(
                  child: new CircularProgressIndicator(),
                  width: 16.0,
                  height: 16.0,
                ),
          onPressed: isLoading
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
        ),
      ],
    );
  }
}

class MajalahCard extends StatelessWidget {
  final Majalah majalah;

  MajalahCard({Key key, this.majalah}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: new EdgeInsets.symmetric(vertical: 8.0),
        decoration: new BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Theme.of(context).disabledColor,
            )
          ],
        ),
        child: new ListTile(
          isThreeLine: true,
          title: new Text(majalah.title),
          subtitle: new Column(
            children: <Widget>[
              new Text(majalah.description),
              new Container(
                margin: new EdgeInsets.only(top: 8.0),
                child: new Text(
                    "${new DateFormat("yMMMd").format(majalah.dateTimeCreated)} - ${new DateFormat.Hms().format(majalah.dateTimeCreated)}",
                    style: new TextStyle(
                      color: Theme.of(context).disabledColor,
                      fontSize: 12.0,
                    )),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          leading: new CircleAvatar(
            backgroundImage: new NetworkImage(majalah.creator.photoUrl),
          ),
          trailing: new IconButton(
            icon: new Icon(
              Icons.delete,
            ),
            onPressed: () async {
              showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) =>
                      new ConfirmDeleteDialog(majalah));
            },
          ),
          onTap: () {
            AndroidIntent intent = new AndroidIntent(
              action: 'action_view',
              data: majalah.downloadUrl,
            );
            intent.launch();
          },
        ));
  }
}

class ApotekerMajalahScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Expanded(
              child: new StreamBuilder(
                  stream: getMajalahCollectionReference().snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return new Center(
                        child: new CircularProgressIndicator(),
                      );
                    }
                    final User currentUser =
                        StoreProvider.of<AppState>(context).state.currentUser;
                    final data = snapshot.data.documents
                        .map((ds) =>
                            new Majalah.fromJson(ds.data)..id = ds.documentID)
                        .toList();
                    return new ListView.builder(
                        itemCount: data.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index > 0)
                            return new MajalahCard(majalah: data[index-1]);
                          else
                            return FullWidthWidget(
                              child: new RaisedButton(
                                child: new Text("Input Majalah Baru", style: new TextStyle(
                                  color: Colors.white,
                                )),
                                onPressed: () => Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        builder: (_) =>
                                            new InputMajalahScreen())),
                              ),
                            );
                        });
                  }))
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      margin: new EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
    );
  }
}

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
    return Scaffold(
      appBar: new AppBar(title: new Text("Input Majalah Baru")),
      body: new Builder(
        builder: (context) => new Container(
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
                            bool isStoragePermissionGranted =
                                await SimplePermissions.checkPermission(
                                    Permission.WriteExternalStorage);
                            if (!isStoragePermissionGranted) {
                              await SimplePermissions.requestPermission(
                                  Permission.WriteExternalStorage);
                            }
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
                            width: 16.0,
                            height: 16.0,
                            child: new CircularProgressIndicator()),
                    color: Theme.of(context).primaryColor,
                    onPressed: _isLoading
                        ? null
                        : () async {
                            try {
                              if (_title == null || _title.isEmpty)
                                throw "Judul Majalah tidak boleh kosong.";
                              if (_description == null || _description.isEmpty)
                                throw "Deskripsi Majalah tidak boleh kosong.";
                              if (_file == null)
                                throw "File Majalah tidak boleh kosong.";
                              setState(() => _isLoading = true);
                              DocumentReference majalahDocumentReference =
                                  await createMajalah(
                                title: _title,
                                description: _description,
                                creator: StoreProvider
                                    .of<AppState>(context)
                                    .state
                                    .currentUser,
                                file: _file,
                              );
                              setState(() => _isLoading = false);
                              Scaffold.of(context).showSnackBar(
                                    new SnackBar(
                                      content: new Text(
                                          "Majalah \"$_title\" berhasil ter-upload."),
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                  );
                              Navigator.of(context).pop();
                            } catch (e) {
                              Scaffold.of(context).showSnackBar(
                                  new SnackBar(content: new Text(e.toString())));
                            }
                          },
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
