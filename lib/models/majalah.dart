import 'package:tuberculos/models/user.dart';

class Majalah {
  String title;
  String description;
  String downloadUrl;
  DateTime dateTimeCreated;
  User creator;

  Majalah({
    this.title,
    this.description,
    this.downloadUrl,
    this.dateTimeCreated,
    this.creator,
  });

  Majalah.fromJson(Map<dynamic, dynamic> jsonObject)
      : title = jsonObject["title"],
        description = jsonObject["description"],
        downloadUrl = jsonObject["downloadUrl"],
        dateTimeCreated = jsonObject["dateTimeCreated"],
        creator = new User.createSpecificUserFromJson(jsonObject["writer"]);

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "downloadUrl": downloadUrl,
        "dateTimeCreated": dateTimeCreated,
        "writer": creator.toJson(),
      };
}
