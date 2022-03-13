
import 'package:takas_app/models/user.dart';

enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  weakPassword,
  undefined,
}

class AuthExceptionHandler {

  static handleException(e) {
    AuthResultStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthResultStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthResultStatus.wrongPassword;
        break;
      case "user-not-found":
        status = AuthResultStatus.userNotFound;
        break;
      case "user-disabled":
        status = AuthResultStatus.userDisabled;
        break;
      case "weak-password":
        status = AuthResultStatus.weakPassword;
        break;
      case "operation-not-allowed":
        status = AuthResultStatus.operationNotAllowed;
        break;
      case "email-already-in-use":
        status = AuthResultStatus.emailAlreadyExists;
        break;
      default:
        status = AuthResultStatus.undefined;
    }
    return status;
  }

  ///
  /// Accepts AuthExceptionHandler.errorType
  ///
  static generateExceptionMessage(exceptionCode) {
    String errorMessage;
    switch (exceptionCode) {
      case AuthResultStatus.invalidEmail:
        errorMessage = "E-posta adresiniz hatalı biçimlendirilmiş görünüyor.";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage = "Şifreniz yanlış.";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "Bu e-postaya sahip kullanıcı mevcut değil.";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage = "Bu e-postaya sahip kullanıcı devre dışı bırakıldı.";
        break;
      case AuthResultStatus.weakPassword:
        errorMessage = "Şifre yeterince güçlü değil.";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage = "E-posta ve Parola ile oturum açma etkin değil.";
        break;
      case AuthResultStatus.emailAlreadyExists:
        errorMessage =
        "E-posta zaten kayıtlı. Lütfen giriş yapın veya şifrenizi sıfırlayın.";
        break;
      default:
        errorMessage = "An undefined Error happened.";
    }

    return errorMessage;
  }
}