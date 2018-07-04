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

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is Pasien) {
      return super == other &&
          chatId == other.chatId &&
          apoteker == other.apoteker &&
          isVerified == other.isVerified &&
          tuberculosStage == other.tuberculosStage;
    }
    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode ^ chatId.hashCode ^ apoteker.hashCode ^ isVerified.hashCode ^ tuberculosStage.hashCode;
  
}
