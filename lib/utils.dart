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
