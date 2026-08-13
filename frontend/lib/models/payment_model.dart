import 'package:frontend/config/api_config.dart';
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
    final int paymentId = json['id'];

    // Bangun URL bukti pembayaran dari sisi Flutter menggunakan ApiConfig.baseUrl
    // sehingga Android otomatis pakai ngrok, Web/Windows pakai localhost.
    // Backend hanya dipakai untuk mengetahui apakah proof sudah diupload (tidak null).
    final bool hasProof = json['proof_image'] != null || json['proof_image_url'] != null;
    final String? proofUrl = hasProof
        ? '${ApiConfig.baseUrl}/payments/$paymentId/proof'
        : null;

    return PaymentModel(
      id: paymentId,
      userId: json['user_id'],
      amount: (json['amount'] is String) ? double.parse(json['amount']) : (json['amount'] as num).toDouble(),
      mandatoryFee: (json['mandatory_fee'] is String) ? double.parse(json['mandatory_fee']) : (json['mandatory_fee'] as num).toDouble(),
      allocationType: json['allocation_type'] ?? 'DONATION',
      paymentStatus: json['payment_status'] ?? 'PENDING',
      paymentMonth: json['payment_month'] ?? '',
      proofImage: proofUrl,
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
