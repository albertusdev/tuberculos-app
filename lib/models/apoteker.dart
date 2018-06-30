import "user.dart";

class Apoteker extends User {
  String alamatApotek;
  String namaApotek;
  String sipa;

  Apoteker();

  Apoteker.fromJson(Map<dynamic, dynamic> json)
      : alamatApotek = json["alamatApotek"],
        namaApotek = json["namaApotek"],
        sipa = json["sipa"],
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json["alamatApotek"] = alamatApotek;
    json["namaApotek"] = namaApotek;
    json["sipa"] = sipa;

    return json;
  }

}
