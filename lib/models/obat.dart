class Obat {
  String id;
  String photoUrl;
  String name;
  String description;

  Obat({this.id, this.photoUrl, this.name, this.description});

  Obat.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        description = json["description"],
        photoUrl = json["photoUrl"];

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "photoUrl": photoUrl,
      };

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is Obat) {
      return (this.id == other.id &&
          this.name == other.name &&
          this.description == other.description &&
          this.photoUrl == other.photoUrl);
    }
    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode =>
      super.hashCode ^
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      photoUrl.hashCode;
}
