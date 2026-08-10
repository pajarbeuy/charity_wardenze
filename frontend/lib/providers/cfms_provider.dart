import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/models/audit_log_model.dart';
import 'package:frontend/models/notification_model.dart';
import 'package:frontend/models/payment_model.dart';
import 'package:frontend/models/setting_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/withdrawal_model.dart';
import 'package:frontend/services/api_service.dart';

class CfmsProvider extends ChangeNotifier {
  String? token;

  Map<String, dynamic>? memberDashboard;
  Map<String, dynamic>? adminDashboard;
  Map<String, dynamic>? charityTarget;
  SettingModel? settings;

  List<PaymentModel> payments = [];
  List<PaymentModel> pendingPayments = [];
  List<WithdrawalModel> withdrawals = [];
  List<UserModel> users = [];
  List<NotificationModel> notifications = [];
  List<AuditLogModel> auditLogs = [];

  bool isLoading = false;

  void updateToken(String? newToken) {
    token = newToken;
  }

  ApiService get _api => ApiService(token: token);

  Future<void> fetchMemberDashboard() async {
    final res = await _api.get('/dashboard/member');
    memberDashboard = res['data'];
    notifyListeners();
  }

  Future<void> fetchAdminDashboard() async {
    final res = await _api.get('/dashboard/admin');
    adminDashboard = res['data'];
    notifyListeners();
  }

  Future<void> fetchCharityTarget() async {
    final res = await _api.get('/charity-target');
    charityTarget = res['data'];
    notifyListeners();
  }

  Future<void> fetchSettings() async {
    final res = await _api.get('/settings');
    settings = SettingModel.fromJson(res['data']);
    notifyListeners();
  }

  Future<void> fetchPayments() async {
    final res = await _api.get('/payments');
    final List list = res['data']['data'] ?? [];
    payments = list.map((e) => PaymentModel.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> fetchPendingPayments() async {
    final res = await _api.get('/admin/payments/pending');
    final List list = res['data']['data'] ?? [];
    pendingPayments = list.map((e) => PaymentModel.fromJson(e)).toList();
    notifyListeners();
  }

  Future<PaymentModel> createPayment(double amount, String allocationType) async {
    final res = await _api.post('/payments', {
      'amount': amount,
      'allocation_type': allocationType,
    });
    final p = PaymentModel.fromJson(res['data']);
    await fetchPayments();
    return p;
  }

  Future<void> uploadProof(int paymentId, String? filePath, {Uint8List? bytes, String? filename}) async {
    await _api.uploadFile(
      '/payments/$paymentId/proof',
      filePath,
      'proof',
      bytes: bytes,
      filename: filename,
    );
    await fetchPayments();
  }

  Future<void> verifyPayment(int paymentId, String? note) async {
    await _api.patch('/admin/payments/$paymentId/verify', {'note': note});
    await fetchPendingPayments();
    await fetchAdminDashboard();
  }

  Future<void> rejectPayment(int paymentId, String reason) async {
    await _api.patch('/admin/payments/$paymentId/reject', {'reason': reason});
    await fetchPendingPayments();
  }

  Future<void> fetchWithdrawals() async {
    final res = await _api.get('/withdrawals');
    final List list = res['data']['data'] ?? [];
    withdrawals = list.map((e) => WithdrawalModel.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> createWithdrawal(double amount, String date, String desc) async {
    await _api.post('/withdrawals', {
      'amount': amount,
      'withdraw_date': date,
      'description': desc,
    });
    await fetchWithdrawals();
    await fetchAdminDashboard();
  }

  Future<void> fetchUsers() async {
    final res = await _api.get('/users');
    final List list = res['data']['data'] ?? [];
    users = list.map((e) => UserModel.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> createUser(String name, String email, String password, String role) async {
    await _api.post('/users', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    await fetchUsers();
  }

  Future<void> fetchNotifications() async {
    final res = await _api.get('/notifications');
    final List list = res['data']['data'] ?? [];
    notifications = list.map((e) => NotificationModel.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> markNotificationRead(int id) async {
    await _api.patch('/notifications/$id/read', {});
    await fetchNotifications();
  }

  Future<void> fetchAuditLogs() async {
    final res = await _api.get('/audit-logs');
    final List list = res['data']['data'] ?? [];
    auditLogs = list.map((e) => AuditLogModel.fromJson(e)).toList();
    notifyListeners();
  }
}
