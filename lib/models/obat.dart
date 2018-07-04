class Obat {
  String id;
  String nama;
  String deskripsi;

  Obat({this.id, this.nama, this.deskripsi});

  Obat.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        nama = json["nama"],
        deskripsi = json["deskripsi"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "deskripsi": deskripsi,
      };

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is Obat) {
      return (this.id == other.id &&
          this.nama == other.nama &&
          this.deskripsi == other.deskripsi);
    }
    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode =>
      super.hashCode ^ id.hashCode ^ nama.hashCode ^ deskripsi.hashCode;
}
