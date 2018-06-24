import "user.dart";

import "dart:convert" as convert;

class Chat {
  List<String> members;
  List<ChatMessage> messages;
}

class ChatMessage {
  String text;
  String imageUrl;
  User sender;
  DateTime sentTimestamp;
  bool isRead;

  ChatMessage({this.text, this.imageUrl, this.sender, this.sentTimestamp, this.isRead});

  ChatMessage.fromJson(Map<dynamic, dynamic> json) {
    if (json != null) {
      text = json["text"];
      imageUrl = json["photo_url"];
      sender = new User.fromJson(json["sender"]);
      sentTimestamp = json["sent_timestamp"];
      isRead = json["is_read"];
    }
  }

  Map<String, dynamic> toJson() => {
    "text": text,
    "photo_url": imageUrl,
    "sender": sender.toJson(),
    "sent_timestamp": sentTimestamp,
    "is_read": isRead,
  };

}