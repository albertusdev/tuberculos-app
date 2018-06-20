import "package:redux/redux.dart";

import "register_field.dart";

enum RegisterActions {
  NextPage,
  PrevPage,
  ChangeUsername,
  ChangePassword,
  ChangeFirstName,
  ChangeLastName,
  SetLoading,
  ClearLoading,
}


class RegisterState {
  static final int maxStep = 3;

  RegisterField emailField = new RegisterField(hintText: "E-mail");
  RegisterField passwordField = new RegisterField(hintText: "Password");
  RegisterField firstNameField = new RegisterField(hintText: "First Name");
  RegisterField lastNameField = new RegisterField(hintText: "Last Name");

  bool isLoading = false;

  int currentStep = 1;

  RegisterState();

  RegisterState.clone(RegisterState prev) {
    currentStep = prev.currentStep;
    isLoading = prev.isLoading;
    emailField = prev.emailField;
    passwordField = prev.passwordField;
    firstNameField = prev.firstNameField;
    lastNameField = prev.lastNameField;
  }
}

RegisterState registerReducer(RegisterState state, action) {
  RegisterState newState = new RegisterState.clone(state);
  switch (action) {
    case RegisterActions.NextPage:
      if (state.currentStep + 1 <= RegisterState.maxStep) {
        newState.currentStep += 1;
      }
      break;
    case RegisterActions.PrevPage:
      if (state.currentStep - 1 >= 1) {
        newState = new RegisterState.clone(state);
        newState.currentStep -= 1;
      }
      break;
    case (RegisterActions.SetLoading):
      newState.isLoading = true;
      break;
    case (RegisterActions.ClearLoading):
      newState.isLoading = false;
      break;
    default:
      break;
  }
  return newState;
}

final void verifyEmail = (Store<RegisterState> store) async {

};