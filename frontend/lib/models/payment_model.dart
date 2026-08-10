import 'package:frontend/models/user_model.dart';

class PaymentModel {
  final int id;
  final int userId;
  final double amount;
  final double mandatoryFee;
  final String allocationType;
  final String paymentStatus;
  final String paymentMonth;
  final String? proofImage;
  final String? rejectionReason;
  final String createdAt;
  final UserModel? user;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.mandatoryFee,
    required this.allocationType,
    required this.paymentStatus,
    required this.paymentMonth,
    this.proofImage,
    this.rejectionReason,
    required this.createdAt,
    this.user,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] is String) ? double.parse(json['amount']) : (json['amount'] as num).toDouble(),
      mandatoryFee: (json['mandatory_fee'] is String) ? double.parse(json['mandatory_fee']) : (json['mandatory_fee'] as num).toDouble(),
      allocationType: json['allocation_type'] ?? 'DONATION',
      paymentStatus: json['payment_status'] ?? 'PENDING',
      paymentMonth: json['payment_month'] ?? '',
      proofImage: json['proof_image_url'] ?? json['proof_image'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
