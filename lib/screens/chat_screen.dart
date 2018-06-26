import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import "package:google_sign_in/google_sign_in.dart";

import 'package:image_picker/image_picker.dart';

import "package:tuberculos/services/api.dart";
import "package:tuberculos/utils.dart";

import "package:tuberculos/models/user.dart";
import "package:tuberculos/models/chat.dart";

@override
class ChatMessageWidget extends StatelessWidget {
  ChatMessageWidget({this.chatMessage, this.animation});
  final ChatMessage chatMessage;
  final Animation animation;

  Widget build(BuildContext context) {
    User owner = chatMessage.sender;
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new CircleAvatar(
              backgroundImage: owner.photoUrl != null
                  ? new NetworkImage(owner.photoUrl)
                  : null,
              child: owner.photoUrl == null
                  ? new Text(getInitialsOfDisplayName(owner.displayName))
                  : null,
            ),
          ),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(owner.displayName,
                    style: Theme.of(context).textTheme.subhead),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: chatMessage.imageUrl != null
                      ? new Image.network(
                          chatMessage.imageUrl,
                          width: 250.0,
                        )
                      : new Text(chatMessage.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final CollectionReference documentRef;
  final GoogleSignIn googleSignIn;

  ChatScreen({Key key, this.documentRef, this.googleSignIn}) : super(key: key);

  @override
  State createState() => new ChatScreenState(documentRef, googleSignIn);
}

class ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = new TextEditingController();
  Animation<double> _animation;
  AnimationController _animationController;

  bool _isComposing = false;
  bool _isUploading = false;
  CollectionReference documentRef;
  GoogleSignIn googleSignIn;

  ChatScreenState(CollectionReference documentRef, GoogleSignIn googleSignIn) {
    print ("Create chat screen state");
    print(documentRef);
    this.documentRef = documentRef;
    this.googleSignIn = googleSignIn ?? new GoogleSignIn();
    if (this.googleSignIn.currentUser == null) {
      this.googleSignIn.signInSilently();
      if (this.googleSignIn.currentUser == null) {
        this.googleSignIn.signIn();
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _animation = new Tween(begin: 0.0, end: 300.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    _animationController.forward();
  }

  Future<Null> _sendMessage({String text, String imageUrl}) async {
    assert(googleSignIn.currentUser != null);
    User sender = new User.fromGoogleSignInAccount(googleSignIn.currentUser);
    ChatMessage chatMessage = new ChatMessage(
      imageUrl: imageUrl,
      isRead: false,
      sender: sender,
      sentTimestamp: new DateTime.now(),
      text: text,
    );
    print(chatMessage.toJson());
    await documentRef.add(chatMessage.toJson());
  }

  Future<Null> _uploadPicture() async {
    setState(() {
      _isUploading = true;
    });
    File imageFile =
    await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      int random = new Random().nextInt(100000);
      StorageReference ref =
      FirebaseStorage.instance.ref().child("image_$random.jpg");
      StorageUploadTask uploadTask = ref.putFile(imageFile);
      Uri downloadUrl = (await uploadTask.future).downloadUrl;
      await _sendMessage(imageUrl: downloadUrl.toString());
    }
    setState(() {
      _isUploading = false;
    });
  }

  Future<Null> _handleSubmitted(String text) async {
    _textController.clear();
    setState(() => _isComposing = false);
    _sendMessage(text: text);
  }

  Widget _buildTextComposer() {
    Widget textComposer = new Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: _uploadPicture,
            ),
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
    );

    List<Widget> children = <Widget>[];
    if (_isUploading) children.add(new LinearProgressIndicator());
    children.add(textComposer);
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
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
                      child: new CircularProgressIndicator(),
                    );
                  }
                  final data = snapshot.data.documents
                      .map(
                          (document) => new ChatMessage.fromJson(document.data))
                      .toList()
                        ..sort((ChatMessage a, ChatMessage b) =>
                            a.sentTimestamp.compareTo(b.sentTimestamp));
                  final int dataCount = data.length;
                  if (dataCount > 0) {
                    return new ListView.builder(
                      itemCount: dataCount,
                      itemBuilder: (_, int index) {
                        return new ChatMessageWidget(
                            chatMessage: data[index], animation: _animation);
                      },
                    );
                  }
                  return new Center(
                      child: new Text("Belum ada percakapan di sini."));
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
}
