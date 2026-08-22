import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isLoading => _isLoading;

  // Setter manual untuk kemudahan testing
  void setUserAndToken(UserModel? user, String? token) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      await fetchMe();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _authRepository.login(email, password);

      _token = res['data']['token'];
      _user = UserModel.fromJson(res['data']['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchMe() async {
    if (_token == null) return;
    try {
      _user = await _authRepository.fetchMe(_token!);
      notifyListeners();
    } catch (e) {
      await logout();
    }
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    Uint8List? avatarBytes,
    String? avatarPath,
    String? filename,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authRepository.updateProfile(
        token: _token,
        name: name,
        phone: phone,
        avatarBytes: avatarBytes,
        avatarPath: avatarPath,
        filename: filename,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAvatar() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authRepository.deleteAvatar(_token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      await _authRepository.logout(_token);
    }
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
}
