import "user.dart";

class Pasien extends User {
  String documentId;
  String chatId;
  String apoteker;
  bool isVerified;
  int tuberculosStage;

  Pasien();

  Pasien.fromJson(Map<dynamic, dynamic> json, [String documentId])
      : chatId = json["chatId"],
        apoteker = json["apoteker"],
        isVerified = json["isVerified"],
        tuberculosStage = json["tuberculosStage"],
        this.documentId = documentId,
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json["chatId"] = chatId;
    json["apoteker"] = apoteker;
    json["isVerified"] = isVerified;
    json["tuberculosStage"] = tuberculosStage;
    return json;
  }

}
