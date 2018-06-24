import "package:flutter/services.dart";

var emailRegex =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

bool isEmail(String str) {
  RegExp regExp = new RegExp(emailRegex);
  return regExp.hasMatch(str);
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return new TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

String getInitialsOfDisplayName(String displayName) {
  List<String> names = displayName.split(" ");
  if (names.length > 1) {
    names = [names[0], names.last];
  }
  print(names);
  return displayName.split(" ").fold(
      "", (String prev, String cur) => prev + (cur.length > 0 ? cur[0] : ""));
}
