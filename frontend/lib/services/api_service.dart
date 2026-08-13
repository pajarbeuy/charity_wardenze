import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';

class ApiService {
  final String? token;

  ApiService({this.token});

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.get(url, headers: ApiConfig.headers(token));
    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.post(
      url,
      headers: ApiConfig.headers(token),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.put(
      url,
      headers: ApiConfig.headers(token),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.patch(
      url,
      headers: ApiConfig.headers(token),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.delete(url, headers: ApiConfig.headers(token));
    if (response.statusCode == 204) return true;
    return _processResponse(response);
  }

  Future<dynamic> uploadFile(
    String endpoint,
    String? filePath,
    String fieldName, {
    Uint8List? bytes,
    String? filename,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename ?? 'proof.jpg',
      ));
    } else if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    } else {
      throw Exception('No file or bytes provided for upload');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response);
  }

  Future<dynamic> updateProfileMultipart({
    required String name,
    String? phone,
    Uint8List? bytes,
    String? filePath,
    String? filename,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/profile');
    final request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields['name'] = name;
    if (phone != null) request.fields['phone'] = phone;
    request.fields['_method'] = 'PUT';

    if (bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'avatar',
        bytes,
        filename: filename ?? 'avatar.jpg',
      ));
    } else if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', filePath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = body['message'] ?? 'Request failed with status: ${response.statusCode}';
      throw Exception(message);
    }
  }
}
