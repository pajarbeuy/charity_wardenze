import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/models/audit_log_model.dart';
import 'package:frontend/models/notification_model.dart';
import 'package:frontend/models/payment_model.dart';
import 'package:frontend/models/setting_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/withdrawal_model.dart';
import 'package:frontend/repositories/cfms_repository.dart';

class CfmsProvider extends ChangeNotifier {
  final CfmsRepository _repository;

  String? token;

  Map<String, dynamic>? memberDashboard;
  Map<String, dynamic>? adminDashboard;
  Map<String, dynamic>? charityTarget;
  Map<String, dynamic>? monthlyStatus;
  Map<int, double>? monthlyIncome;
  SettingModel? settings;

  List<PaymentModel> payments = [];
  List<PaymentModel> pendingPayments = [];
  List<WithdrawalModel> withdrawals = [];
  List<UserModel> users = [];
  List<NotificationModel> notifications = [];
  List<AuditLogModel> auditLogs = [];

  bool isLoading = false;

  CfmsProvider({CfmsRepository? repository})
      : _repository = repository ?? CfmsRepository();

  void updateToken(String? newToken) {
    token = newToken;
  }

  Future<void> fetchMemberDashboard() async {
    memberDashboard = await _repository.fetchMemberDashboard(token);
    notifyListeners();
  }

  Future<void> fetchAdminDashboard() async {
    adminDashboard = await _repository.fetchAdminDashboard(token);
    notifyListeners();
  }

  Future<void> fetchCharityTarget() async {
    charityTarget = await _repository.fetchCharityTarget(token);
    notifyListeners();
  }

  Future<void> fetchMonthlyStatus({String? month}) async {
    monthlyStatus = await _repository.fetchMonthlyStatus(token, month);
    notifyListeners();
  }

  Future<void> fetchMonthlyIncome() async {
    monthlyIncome = await _repository.fetchMonthlyIncome(token);
    notifyListeners();
  }

  Future<void> fetchSettings() async {
    settings = await _repository.fetchSettings(token);
    notifyListeners();
  }

  Future<void> fetchPayments() async {
    payments = await _repository.fetchPayments(token);
    notifyListeners();
  }

  Future<void> fetchPendingPayments() async {
    pendingPayments = await _repository.fetchPendingPayments(token);
    notifyListeners();
  }

  Future<PaymentModel> createPayment(double amount, String allocationType) async {
    final p = await _repository.createPayment(token, amount, allocationType);
    await fetchPayments();
    return p;
  }

  Future<void> uploadProof(int paymentId, String? filePath, {Uint8List? bytes, String? filename}) async {
    await _repository.uploadProof(
      token,
      paymentId,
      filePath,
      bytes: bytes,
      filename: filename,
    );
    await fetchPayments();
  }

  Future<void> verifyPayment(int paymentId, String? note) async {
    await _repository.verifyPayment(token, paymentId, note);
    await fetchPendingPayments();
    await fetchAdminDashboard();
  }

  Future<void> rejectPayment(int paymentId, String reason) async {
    await _repository.rejectPayment(token, paymentId, reason);
    await fetchPendingPayments();
  }

  Future<void> fetchWithdrawals() async {
    withdrawals = await _repository.fetchWithdrawals(token);
    notifyListeners();
  }

  Future<void> createWithdrawal(double amount, String date, String desc) async {
    await _repository.createWithdrawal(token, amount, date, desc);
    await fetchWithdrawals();
    await fetchAdminDashboard();
  }

  Future<void> fetchUsers() async {
    users = await _repository.fetchUsers(token);
    notifyListeners();
  }

  Future<void> createUser(String name, String email, String password, String role) async {
    await _repository.createUser(token, name, email, password, role);
    await fetchUsers();
  }

  Future<void> resetUserPassword(int userId, String newPassword) async {
    await _repository.resetUserPassword(token, userId, newPassword);
    await fetchUsers();
  }

  Future<void> fetchNotifications() async {
    notifications = await _repository.fetchNotifications(token);
    notifyListeners();
  }

  Future<void> markNotificationRead(int id) async {
    await _repository.markNotificationRead(token, id);
    await fetchNotifications();
  }

  Future<void> fetchAuditLogs() async {
    auditLogs = await _repository.fetchAuditLogs(token);
    notifyListeners();
  }
}
