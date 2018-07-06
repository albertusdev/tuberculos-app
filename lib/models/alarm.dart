import 'package:meta/meta.dart';
import 'package:tuberculos/models/obat.dart';
import 'package:tuberculos/models/user.dart';

class Alarm {
  User user;
  Obat obat;
  DateTime dateTime;
  bool taken = false;
  String message;

  Alarm({
    @required this.user,
    @required this.obat,
    @required this.dateTime,
    @required this.message,
    this.taken = false,
  });

  Alarm.fromJson(Map<String, dynamic> json)
      : user = new User.createSpecificUserFromJson(json["user"]),
        obat = new Obat.fromJson(json["obat"]),
        dateTime = json["dateTime"],
        taken = json["taken"],
        message = json["message"];

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "obat": obat.toJson(),
        "dateTime": dateTime,
        "taken": taken,
        "message": message
      };

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is Alarm) {
      return (this.user == other.user &&
          this.obat == other.obat &&
          this.dateTime == other.dateTime &&
          this.message == other.message &&
          this.taken == other.taken);
    }
    return false;
  }

  @override
  // TODO: implement hashCode
  int get hashCode =>
      super.hashCode ^
      user.hashCode ^
      obat.hashCode ^
      dateTime.hashCode ^
      message.hashCode ^
      taken.hashCode;
}
