import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isLoading => _isLoading;

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
      final res = await ApiService().post('/auth/login', {
        'email': email,
        'password': password,
      });

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
      final res = await ApiService(token: _token).get('/auth/me');
      _user = UserModel.fromJson(res['data']);
      notifyListeners();
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await ApiService(token: _token).post('/auth/logout', {});
      } catch (_) {}
    }
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
}
