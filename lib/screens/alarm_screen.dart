import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import "package:intl/intl.dart";
import 'package:tuberculos/models/alarm.dart';
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/models/chat.dart';
import 'package:tuberculos/models/pasien.dart';
import 'package:tuberculos/models/user.dart';
import 'package:tuberculos/services/api.dart';
import 'package:tuberculos/utils.dart';
import 'package:tuberculos/widgets/full_width_widget.dart';

class AlarmScreen extends StatefulWidget {
  final Alarm alarm;

  AlarmScreen(this.alarm);

  @override
  AlarmScreenState createState() {
    return new AlarmScreenState(alarm);
  }
}

class AlarmScreenState extends State<AlarmScreen> {
  Alarm alarm;
  Apoteker apoteker;

  AlarmScreenState(this.alarm);

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (alarm == null) {
      Firestore.instance
          .document(
              "pasiens/albertusangga.r@gmail.com/alarms/-LGtP0-pOBpNiIRMc2UQ")
          .get()
          .then((ds) {
        alarm = new Alarm.fromJson(ds.data)..id = ds.documentID;
        setState(() {});
        Pasien pasien = alarm.user;
        getUserDocumentReference(role: User.APOTEKER, email: pasien.apoteker)
            .get()
            .then((DocumentSnapshot ds) {
          apoteker = new Apoteker.fromJson(ds.data);
        });
      });
    }
  }
  
  void _handleYes(BuildContext context) {
    showDialog<File>(
      context: context,
      builder: (BuildContext context) => new Dialog(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  alignment: Alignment.center,
                  child: new Text(
                    "Upload Foto Bukti Minum Obat Anda",
                    style: new TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 24.0),
                    textAlign: TextAlign.center,
                  ),
                  margin: new EdgeInsets.only(
                      top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
                ),
                new Container(
                  margin: new EdgeInsets.symmetric(vertical: 16.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new IconButton(
                        icon: new Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          File file = await ImagePicker.pickImage(
                              source: ImageSource.camera);
                          Navigator.of(context).pop(file);
                        },
                        iconSize: 40.0,
                      ),
                      new IconButton(
                        icon: new Icon(
                          Icons.photo,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          File file = await ImagePicker.pickImage(
                              source: ImageSource.gallery);
                          Navigator.of(context).pop(file);
                        },
                        iconSize: 40.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    ).then((File file) async {
      setState(() => isLoading = true);
      String photoUrl = await uploadFile(file);
      getAlarmDocumentReference(pasienId: alarm.user.email, alarmId: alarm.id)
          .updateData({
        "taken": true,
        "photoUrl": photoUrl,
      });
      ChatMessage chatMessage = new ChatMessage(
        imageUrl: photoUrl,
        isRead: false,
        sender: alarm.user,
        sentTimestamp: new DateTime.now(),
      );
      Pasien pasien = alarm.user;
      await getMessageCollectionReference(pasien.chatId)
          .add(chatMessage.toJson());
      if (apoteker == null) {
        DocumentSnapshot apotekerDs = await getUserDocumentReference(
                role: User.APOTEKER, email: pasien.apoteker)
            .get();
        apoteker = new Apoteker.fromJson(apotekerDs.data);
      }
      try {
        final body = {
          "include_player_ids": [apoteker.oneSignalPlayerId],
          "headings": {"en": pasien.displayName},
          "contents": {"en": "Mengirim bukti minum obat ${alarm.obat.name}"},
          "large_icon": pasien.photoUrl,
          "data": {
            "type": "chat",
            "currentUser": pasien.toJson()..remove("dateTimeCreated"),
            "otherUser": apoteker.toJson()..remove("dateTimeCreated"),
            "chatId": pasien.chatId,
          }
        };
        final response = await OneSignalHttpClient.post(body: body);
        Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text(
                  "Terimakasih! Apoteker mu sudah menerima bukti minum obatmu."),
              backgroundColor: Theme.of(context).primaryColor,
            ));
        if (Navigator.canPop(context)) Navigator.pop(context);
      } catch (e) {
        print(e.toString());
      }
      setState(() => isLoading = false);
    });
  }

  void _handleNo(BuildContext context) {
    showDialog<bool>(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
              title: new Text("Apakah anda yakin ingin menunda?"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    "Ya",
                    style: new TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                new FlatButton(
                  child: new Text(
                    "Tidak",
                    style: new TextStyle(
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            )).then((bool confirmed) async {
      if (!confirmed) return;
      setState(() => isLoading = true);
      Pasien pasien = alarm.user;
      if (apoteker == null) {
        DocumentSnapshot apotekerDs = await getUserDocumentReference(
            role: User.APOTEKER, email: pasien.apoteker)
            .get();
        apoteker = new Apoteker.fromJson(apotekerDs.data);
      }
      try {
        final body = {
          "include_player_ids": [apoteker.oneSignalPlayerId],
          "headings": {"en": pasien.displayName},
          "contents": {"en": "${pasien.displayName} menunda meminum obat ${alarm.obat.name}"},
          "large_icon": pasien.photoUrl,
          "data": {
            "type": "chat",
            "currentUser": pasien.toJson()..remove("dateTimeCreated"),
            "otherUser": apoteker.toJson()..remove("dateTimeCreated"),
            "chatId": pasien.chatId,
          }
        };
        final response = await OneSignalHttpClient.post(body: body);
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(
              "Apoteker mu mendapatkan notifikasi mengenai ini."),
          backgroundColor: Colors.red,
        ));
        if (Navigator.canPop(context)) Navigator.pop(context);
      } catch (e) {
        print(e.toString());
      }
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (alarm == null) {
      return new Scaffold(
        body: new Container(),
      );
    }
    return new WillPopScope(
      onWillPop: () {
        print("Back Button is pressed..");
        return new Future<bool>.value(false);
      },
      child: new Scaffold(
        body: new Builder(
          builder: (BuildContext context) => new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Flexible(
                    child: new FullWidthWidget(
                      child: new Container(
                        child: new Column(
                          children: <Widget>[
                            new Icon(
                              Icons.alarm,
                              size: 80.0,
                              color: Colors.white,
                            ),
                            new Container(
                              margin: new EdgeInsets.only(top: 4.0),
                              child: new Text(
                                new DateFormat.Hm().format(alarm.dateTime),
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 40.0,
                                ),
                              ),
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        decoration: new BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: new BorderRadius.only(
                            bottomLeft: new Radius.elliptical(256.0, 64.0),
                            bottomRight: new Radius.elliptical(256.0, 64.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  new Flexible(
                    flex: 2,
                    child: new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 32.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            alarm.message,
                            style: new TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w200,
                              fontSize: 18.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          new Container(
                            child: new Row(children: <Widget>[
                              new Image.network(
                                alarm.obat.photoUrl,
                                width: 64.0,
                              ),
                              new Expanded(
                                child: new Text(
                                  alarm.obat.name,
                                  style: new TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 22.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ]),
                            decoration: new BoxDecoration(
                              color: Theme.of(context).cardColor,
                              boxShadow: <BoxShadow>[
                                new BoxShadow(
                                  color: Theme.of(context).disabledColor,
                                )
                              ],
                            ),
                            margin: new EdgeInsets.only(top: 16.0),
                            padding: new EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16.0),
                          ),
                          new Container(
                            child: new Text(
                              "Sudahkan anda minum obat ?",
                              style: new TextStyle(
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1.0,
                                fontSize: 26.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            margin: new EdgeInsets.only(top: 24.0, bottom: 24.0),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new RaisedButton(
                                child: new Text(
                                  "Sudah",
                                  style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                                color: Theme.of(context).primaryColor,
                                onPressed:
                                    isLoading ? null : () => _handleYes(context),
                                padding: new EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 24.0),
                              ),
                              new Container(
                                margin: new EdgeInsets.only(left: 24.0),
                                child: new RaisedButton(
                                  child: new Text(
                                    "Tunda",
                                    style: new TextStyle(
                                        color: Colors.white, fontSize: 20.0),
                                  ),
                                  color: Colors.red,
                                  onPressed:
                                      isLoading ? null : () => _handleNo(context),
                                  padding: new EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 24.0),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        ),
        bottomNavigationBar: isLoading ? new LinearProgressIndicator() : null,
      ),
    );
  }
}
