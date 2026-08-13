/// Model untuk tabel payment_allocations.
///
/// Menyimpan detail alokasi pembayaran ketika user membayar lebih dari
/// kewajiban bulanan. Misalnya bayar Rp30.000 → bisa dialokasikan menjadi
/// iuran Juli (MONTHLY) + donasi tambahan (DONATION) atau lanjut ke bulan
/// berikutnya.
class PaymentAllocationModel {
  final int id;
  final int paymentId;
  final int userId;

  /// Bulan alokasi dalam format ISO date, contoh: "2026-08-01".
  /// Null jika tipe adalah DONATION (tidak terikat bulan).
  final String? allocationMonth;

  final double amount;

  /// Jenis alokasi: "MONTHLY" atau "DONATION".
  final String allocationType;

  PaymentAllocationModel({
    required this.id,
    required this.paymentId,
    required this.userId,
    this.allocationMonth,
    required this.amount,
    required this.allocationType,
  });

  factory PaymentAllocationModel.fromJson(Map<String, dynamic> json) {
    return PaymentAllocationModel(
      id: json['id'],
      paymentId: json['payment_id'],
      userId: json['user_id'],
      allocationMonth: json['allocation_month'],
      amount: (json['amount'] is String)
          ? double.parse(json['amount'])
          : (json['amount'] as num).toDouble(),
      allocationType: json['allocation_type'] ?? 'MONTHLY',
    );
  }

  /// Apakah alokasi ini merupakan iuran bulanan.
  bool get isMonthly => allocationType == 'MONTHLY';

  /// Apakah alokasi ini merupakan donasi tambahan.
  bool get isDonation => allocationType == 'DONATION';
}
