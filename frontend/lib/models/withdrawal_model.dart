class WithdrawalModel {
  final int id;
  final int userId;
  final double amount;
  final String withdrawDate;
  final String description;
  final String createdAt;

  WithdrawalModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.withdrawDate,
    required this.description,
    required this.createdAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'],
      userId: json['user_id'],
      amount: (json['amount'] is String) ? double.parse(json['amount']) : (json['amount'] as num).toDouble(),
      withdrawDate: json['withdraw_date'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
