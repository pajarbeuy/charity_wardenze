class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

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
