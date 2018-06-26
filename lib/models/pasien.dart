import "user.dart";

class Pasien extends User {
  final String chatId;
  final String apoteker;
  final bool isVerified;
  final String tuberculosStage;

  Pasien();

  Pasien.fromJson(Map<dynamic, dynamic> json)
      : chatId = json["chatId"],
        apoteker = json["apoteker"],
        isVerified = json["isVerified"],
        tuberculosStage = json["tuberculosStage"],
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
