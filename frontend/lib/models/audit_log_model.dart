import 'package:frontend/models/user_model.dart';

class AuditLogModel {
  final int id;
  final int? userId;
  final String action;
  final String? ipAddress;
  final String createdAt;
  final UserModel? user;

  AuditLogModel({
    required this.id,
    this.userId,
    required this.action,
    this.ipAddress,
    required this.createdAt,
    this.user,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'],
      userId: json['user_id'],
      action: json['action'] ?? '',
      ipAddress: json['ip_address'],
      createdAt: json['created_at'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
