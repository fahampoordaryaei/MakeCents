import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<TotpSecret> startTotpSession({User? user}) async {
  final u = user ?? FirebaseAuth.instance.currentUser!;
  final session = await u.multiFactor.getSession();
  return TotpMultiFactorGenerator.generateSecret(session);
}

Future<void> completeTotp({
  required TotpSecret totpSecret,
  required String oneTimePassword,
  required String displayName,
  User? user,
}) async {
  final u = user ?? FirebaseAuth.instance.currentUser!;
  final assertion = await TotpMultiFactorGenerator.getAssertionForEnrollment(
    totpSecret,
    oneTimePassword.trim(),
  );
  await u.multiFactor.enroll(assertion, displayName: displayName);
}

class MfaProvider with ChangeNotifier {
  static const String _totpFactorId = 'totp';

  FirebaseAuthMultiFactorException? _mfaException;
  String _message = '';
  bool _totpEnrolled = false;

  MultiFactorResolver? get resolver => _mfaException?.resolver;
  bool get hasPendingSignIn => _mfaException != null;
  String get message => _message;
  bool get totpEnrolled => _totpEnrolled;

  void setMessage(String value) {
    _message = value;
    notifyListeners();
  }

  void clearMessage() {
    _message = '';
    notifyListeners();
  }

  void captureMultiFactorException(FirebaseAuthMultiFactorException e) {
    _mfaException = e;
    notifyListeners();
  }

  void clearPendingSignIn() {
    _mfaException = null;
    notifyListeners();
  }

  Future<void> refreshEnrollmentState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _totpEnrolled = false;
      notifyListeners();
      return;
    }
    try {
      final factors = await user.multiFactor.getEnrolledFactors();
      _totpEnrolled = factors.any((f) => f.factorId == _totpFactorId);
    } catch (_) {
      _totpEnrolled = false;
    }
    notifyListeners();
  }
}

Widget buildQrCodeView(
  String data, {
  double size = 200,
  Color backgroundColor = Colors.white,
  Color foregroundColor = Colors.black,
}) {
  return QrImageView(
    data: data,
    version: QrVersions.auto,
    size: size,
    backgroundColor: backgroundColor,
    eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: foregroundColor),
    dataModuleStyle: QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: foregroundColor,
    ),
  );
}

Future<Widget> buildTotpEnrollmentQrView({
  required TotpSecret secret,
  String? accountName,
  String? issuer,
  double size = 200,
  Color backgroundColor = Colors.white,
  Color foregroundColor = Colors.black,
}) async {
  final uri = await secret.generateQrCodeUrl(
    accountName: accountName,
    issuer: issuer,
  );
  return buildQrCodeView(
    uri,
    size: size,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
  );
}
