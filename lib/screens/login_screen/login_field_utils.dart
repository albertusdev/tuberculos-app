import "package:flutter/material.dart";

class LoginFieldUtils {
  Function validator;
  final controller = TextEditingController();
  final String hintText;
  String errorText = "";

  LoginFieldUtils({this.hintText, this.errorText, this.validator});

  bool get isValid {
    if (validator == null) return true;
    return validator(controller.text);
  }
}