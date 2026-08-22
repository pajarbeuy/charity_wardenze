import 'dart:typed_data';
import 'package:frontend/models/audit_log_model.dart';
import 'package:frontend/models/notification_model.dart';
import 'package:frontend/models/payment_model.dart';
import 'package:frontend/models/setting_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/withdrawal_model.dart';
import 'package:frontend/services/api_service.dart';

class CfmsRepository {
  ApiService _api(String? token) => ApiService(token: token);

  Future<Map<String, dynamic>> fetchMemberDashboard(String? token) async {
    final res = await _api(token).get('/dashboard/member');
    return res['data'];
  }

  Future<Map<String, dynamic>> fetchAdminDashboard(String? token) async {
    final res = await _api(token).get('/dashboard/admin');
    return res['data'];
  }

  Future<Map<String, dynamic>> fetchCharityTarget(String? token) async {
    final res = await _api(token).get('/charity-target');
    return res['data'];
  }

  Future<SettingModel> fetchSettings(String? token) async {
    final res = await _api(token).get('/settings');
    return SettingModel.fromJson(res['data']);
  }

  Future<List<PaymentModel>> fetchPayments(String? token) async {
    final res = await _api(token).get('/payments');
    final List list = res['data']['data'] ?? [];
    return list.map((e) => PaymentModel.fromJson(e)).toList();
  }

  Future<List<PaymentModel>> fetchPendingPayments(String? token) async {
    final res = await _api(token).get('/admin/payments/pending');
    final List list = res['data']['data'] ?? [];
    return list.map((e) => PaymentModel.fromJson(e)).toList();
  }

  Future<PaymentModel> createPayment(String? token, double amount, String allocationType) async {
    final res = await _api(token).post('/payments', {
      'amount': amount,
      'allocation_type': allocationType,
    });
    return PaymentModel.fromJson(res['data']);
  }

  Future<void> uploadProof(String? token, int paymentId, String? filePath, {Uint8List? bytes, String? filename}) async {
    await _api(token).uploadFile(
      '/payments/$paymentId/proof',
      filePath,
      'proof',
      bytes: bytes,
      filename: filename,
    );
  }

  Future<void> verifyPayment(String? token, int paymentId, String? note) async {
    await _api(token).patch('/admin/payments/$paymentId/verify', {'note': note});
  }

  Future<void> rejectPayment(String? token, int paymentId, String reason) async {
    await _api(token).patch('/admin/payments/$paymentId/reject', {'reason': reason});
  }

  Future<List<WithdrawalModel>> fetchWithdrawals(String? token) async {
    final res = await _api(token).get('/withdrawals');
    final List list = res['data']['data'] ?? [];
    return list.map((e) => WithdrawalModel.fromJson(e)).toList();
  }

  Future<void> createWithdrawal(String? token, double amount, String date, String desc) async {
    await _api(token).post('/withdrawals', {
      'amount': amount,
      'withdraw_date': date,
      'description': desc,
    });
  }

  Future<List<UserModel>> fetchUsers(String? token) async {
    final res = await _api(token).get('/users');
    final List list = res['data']['data'] ?? [];
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> createUser(String? token, String name, String email, String password, String role) async {
    await _api(token).post('/users', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  Future<void> resetUserPassword(String? token, int userId, String newPassword) async {
    await _api(token).put('/users/$userId', {'password': newPassword});
  }

  Future<List<NotificationModel>> fetchNotifications(String? token) async {
    final res = await _api(token).get('/notifications');
    final List list = res['data']['data'] ?? [];
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markNotificationRead(String? token, int id) async {
    await _api(token).patch('/notifications/$id/read', {});
  }

  Future<List<AuditLogModel>> fetchAuditLogs(String? token) async {
    final res = await _api(token).get('/audit-logs');
    final List list = res['data']['data'] ?? [];
    return list.map((e) => AuditLogModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> fetchMonthlyStatus(String? token, String? month) async {
    final query = month != null ? '?month=$month' : '';
    final res = await _api(token).get('/statistics/monthly-status$query');
    return res['data'];
  }

  Future<Map<int, double>> fetchMonthlyIncome(String? token) async {
    final res = await _api(token).get('/statistics/income');
    final raw = res['data'] as Map<String, dynamic>;
    return raw.map(
      (k, v) => MapEntry(int.parse(k), (v is String ? double.parse(v) : (v as num).toDouble())),
    );
  }
}
