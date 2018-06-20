enum UserRole {
  pasien,
  apoteker,
}

bool isPasien(String role) {
  return role == UserRole.pasien.toString();
}

bool isApoteker(String role) {
  return role == UserRole.apoteker.toString();
}

var emailRegex =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

bool isEmail(String str) {
  RegExp regExp = new RegExp(emailRegex);
  return regExp.hasMatch(str);
}
