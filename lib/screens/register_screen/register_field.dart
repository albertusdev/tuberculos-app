import "package:flutter/material.dart";

class RegisterField {
  Function validator;
  final controller = TextEditingController();
  final String hintText;
  String errorText = "";

  RegisterField({this.hintText, this.errorText, this.validator});

  bool get isValid {
    if (validator == null) return true;
    return validator(controller.text);
  }

  InputDecoration get decoration {
    return new InputDecoration(
      hintText: hintText,
      errorText: errorText,
    );
  }
}