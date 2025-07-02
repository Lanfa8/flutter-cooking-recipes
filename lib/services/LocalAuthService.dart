
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();


  Future<bool> authenticateOrBypass() async {
    final bool canAuthenticate = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

    if (!canAuthenticate) {
      return true;
    }

    try {
      return await _auth.authenticate(
        localizedReason: 'Por favor, autentique-se para deletar a receita',
        options: const AuthenticationOptions(
          biometricOnly: false,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print("Erro de plataforma na autenticação: $e");
      return false;
    }
  }
}