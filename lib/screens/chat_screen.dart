import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';

import "package:google_sign_in/google_sign_in.dart";

import 'package:image_picker/image_picker.dart';

import "package:tuberculos/services/api.dart";

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

final auth = FirebaseAuth.instance;
final reference = Firestore.instance.document('messages');

const String _name = "Your Name";

final googleSignIn = new GoogleSignIn();

@override
class ChatMessage extends StatelessWidget {
  ChatMessage({this.snapshot, this.animation});
  final DocumentSnapshot snapshot;
  final Animation animation;

  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(
                  backgroundImage:
                      new NetworkImage(snapshot.data['senderPhotoUrl'])),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(snapshot.data['senderName'],
                      style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: snapshot.data['imageUrl'] != null
                        ? new Image.network(
                            snapshot.data['imageUrl'],
                            width: 250.0,
                          )
                        : new Text(snapshot.data['text']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final CollectionReference documentRef;

  ChatScreen({Key key, this.documentRef}) : super(key: key);

  @override
  State createState() => new ChatScreenState(documentRef);
}

class ChatScreenState extends State<ChatScreen> {
  CollectionReference documentRef;
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  ChatScreenState(CollectionReference documentRef) {
    if (documentRef == null) {
      this.documentRef = getMessageCollectionReference("mock");
    } else {
      this.documentRef = documentRef;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(documentRef?.document()?.documentID);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Consultation Chat"),
      ),
      body: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Flexible(
              child: new StreamBuilder(
                stream: documentRef.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  Widget child;
                  if (!snapshot.hasData) {
                    return new Center(
                      child: new Text("Empty messages..."),
                    );
                  }
                  final data = snapshot.data.documents;
                  final int dataCount = data.length;
                  if (dataCount > 0) {
                    child = new ListView.builder(
                      itemCount: dataCount,
                      itemBuilder: (_, int index) {
                        final DocumentSnapshot document = data[index];
                        return new ListTile(
                          title: new Text('${document["sender"]}'),
                          subtitle: new Text(
                              document["message"] ?? '<No message retrieved>'),
                        );
                      },
                    );
                  } else {
                    child = new Center(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                              "Maaf, belum ada Apoteker yang terdaftar dalam sistem."),
                        ],
                      ),
                    );
                  }
                  return child;
                },
              ),
            ),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: new Column(children: <Widget>[
                new Divider(height: 1.0),
                _buildTextComposer(),
              ]),
            ),
          ]),
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.photo_camera),
                  onPressed: () async {
                    File imageFile = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                    int random = new Random().nextInt(100000);
                    StorageReference ref = FirebaseStorage.instance
                        .ref()
                        .child("image_$random.jpg");
                    StorageUploadTask uploadTask = ref.putFile(imageFile);
                    Uri downloadUrl = (await uploadTask.future).downloadUrl;
                    _sendMessage(imageUrl: downloadUrl.toString());
                  }),
            ),
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                )),
          ],
        ),
      ),
    );
  }

  Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    _sendMessage(text: text);
  }

  void _sendMessage({String text, String imageUrl}) {
    documentRef.add({
      "text": text,
      "imageUrl": imageUrl,
      "senderName": googleSignIn.currentUser.displayName,
      "senderPhotoUrl": googleSignIn.currentUser.photoUrl,
      "timestamp": new DateTime.now(),
    });
  }
}
