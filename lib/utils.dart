import "package:flutter/services.dart";

var emailRegex =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

bool isEmail(String str) {
  RegExp regExp = new RegExp(emailRegex);
  return regExp.hasMatch(str);
}

bool isNumeric(String c) {
  assert(c.length == 1);
  return c.codeUnitAt(0) >= "0".codeUnitAt(0) && c.codeUnitAt(0) <= "9".codeUnitAt(0);
}

String capitalize(String s) {
  return s.substring(0, 1).toUpperCase() + s.substring(1);
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

class SipaTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = "";
    for (int i = 0; i < newValue.text.length; ++i) {
      if (isNumeric(newValue.text[i])) {
        newText += newValue.text[i];
      }
    }
    String temp = "";
    if (newText.length <= 12) {
      for (int i = 0; i < newText.length; ++i) {
        if (i > 0 && i % 4 == 0) {
          temp += "-${newText[i]}";
        } else {
          temp += newText[i];
        }
      }
    } else {
      temp = oldValue.text;
    }
    return new TextEditingValue(
      text: temp,
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
