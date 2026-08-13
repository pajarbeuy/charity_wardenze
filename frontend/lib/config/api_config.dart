import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class ApiConfig {
  /// URL ngrok — ganti setiap kali tunnel baru dibuka
  static const String _ngrokUrl  = 'https://crusher-vaguely-tyke.ngrok-free.dev/api/v1';
  static const String _localUrl  = 'http://127.0.0.1:8000/api/v1';

  /// Otomatis memilih base URL berdasarkan platform:
  ///   - Android → ngrok (karena emulator/device tidak bisa akses 127.0.0.1 host)
  ///   - Web / Windows / lainnya → localhost
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _ngrokUrl;
    }
    return _localUrl;
  }

  static Map<String, String> headers([String? token]) {
    final map = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
    }
    return map;
  }
}
