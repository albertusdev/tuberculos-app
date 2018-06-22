// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
      sizeFactor: new CurvedAnimation(
          parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(backgroundImage: new NetworkImage(snapshot.data['senderPhotoUrl'])),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                      snapshot.data['senderName'],
                      style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: snapshot.data['imageUrl'] != null ?
                    new Image.network(
                      snapshot.data['imageUrl'],
                      width: 250.0,
                    ) :
                    new Text(snapshot.data['text']),
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

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Text("Chat Screen");
  }
}
//
//class ChatScreen extends StatefulWidget {
//  final DocumentReference documentRef;
//
//  ChatScreen({Key key, this.documentRef}) : super(key: key);
//
//  @override
//  State createState() => new ChatScreenState(documentRef);
//}
//
//class ChatScreenState extends State<ChatScreen> {
//  final DocumentReference documentRef;
//  final TextEditingController _textController = new TextEditingController();
//  bool _isComposing = false;
//
//  ChatScreenState(this.documentRef);
//
//  @override
//  Widget build(BuildContext context) {
//    return new Column(children: <Widget>[
//          new Flexible(
//            child: new StreamBuilder<DocumentSnapshot>(
//              stream: documentRef.snapshots(),
//            ),
////            child: new FirebaseAnimatedList(
////              query: reference,
////              sort: (a, b) => b.key.compareTo(a.key),
////              padding: new EdgeInsets.all(8.0),
////              reverse: true,
////              itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation) {
////                return new ChatMessage(
////                    snapshot: snapshot,
////                    animation: animation
////                );
////              },
////            ),
//          ),
//          new Divider(height: 1.0),
//          new Container(
//            decoration:
//            new BoxDecoration(color: Theme.of(context).cardColor),
//            child: _buildTextComposer(),
//          ),
//        ]);
//  }
//
//  Widget _buildTextComposer() {
//    return new IconTheme(
//      data: new IconThemeData(color: Theme.of(context).accentColor),
//      child: new Container(
//          margin: const EdgeInsets.symmetric(horizontal: 8.0),
//          child: new Row(children: <Widget>[
//            new Container(
//              margin: new EdgeInsets.symmetric(horizontal: 4.0),
//              child: new IconButton(
//                  icon: new Icon(Icons.photo_camera),
//                  onPressed: () async {
//                    File imageFile = await ImagePicker.pickImage();
//                    int random = new Random().nextInt(100000);
//                    StorageReference ref =
//                    FirebaseStorage.instance.ref().child("image_$random.jpg");
//                    StorageUploadTask uploadTask = ref.putFile(imageFile);
//                    Uri downloadUrl = (await uploadTask.future).downloadUrl;
//                    _sendMessage(imageUrl: downloadUrl.toString());
//                  }
//              ),
//            ),
//            new Flexible(
//              child: new TextField(
//                controller: _textController,
//                onChanged: (String text) {
//                  setState(() {
//                    _isComposing = text.length > 0;
//                  });
//                },
//                onSubmitted: _handleSubmitted,
//                decoration:
//                new InputDecoration.collapsed(hintText: "Send a message"),
//              ),
//            ),
//            new Container(
//                margin: new EdgeInsets.symmetric(horizontal: 4.0),
//                child:new IconButton(
//                  icon: new Icon(Icons.send),
//                  onPressed: _isComposing
//                      ? () => _handleSubmitted(_textController.text)
//                      : null,
//                )),
//          ],
//        ),
//      ),
//    );
//  }
//
//  Future<Null> _handleSubmitted(String text) async {
//    _textController.clear();
//    setState(() {
//      _isComposing = false;
//    });
//    _sendMessage(text: text);
//  }
//
//  void _sendMessage({ String text, String imageUrl }) {
//    reference.push().set({
//      'text': text,
//      'imageUrl': imageUrl,
//      'senderName': googleSignIn.currentUser.displayName,
//      'senderPhotoUrl': googleSignIn.currentUser.photoUrl,
//    });
//  }
//
//}