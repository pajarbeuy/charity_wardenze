import 'dart:typed_data';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return res;
  }

  Future<UserModel> fetchMe(String token) async {
    final res = await ApiService(token: token).get('/auth/me');
    return UserModel.fromJson(res['data']);
  }

  Future<UserModel> updateProfile({
    required String? token,
    required String name,
    String? phone,
    Uint8List? avatarBytes,
    String? avatarPath,
    String? filename,
  }) async {
    dynamic res;
    if (avatarBytes != null || avatarPath != null) {
      res = await ApiService(token: token).updateProfileMultipart(
        name: name,
        phone: phone,
        bytes: avatarBytes,
        filePath: avatarPath,
        filename: filename,
      );
    } else {
      res = await ApiService(token: token).put('/profile', {
        'name': name,
        'phone': phone,
      });
    }
    return UserModel.fromJson(res['data']);
  }

  Future<UserModel> deleteAvatar(String? token) async {
    final res = await ApiService(token: token).delete('/profile/avatar');
    return UserModel.fromJson(res['data']);
  }

  Future<void> logout(String? token) async {
    if (token != null) {
      try {
        await ApiService(token: token).post('/auth/logout', {});
      } catch (_) {}
    }
  }
}
