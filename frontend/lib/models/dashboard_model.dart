import 'package:frontend/models/payment_model.dart';

/// Model untuk response GET /dashboard/member.
///
/// Berisi ringkasan kontribusi member:
/// - Total donasi yang sudah diverifikasi
/// - Jumlah transaksi terverifikasi
/// - Status pembayaran bulan berjalan
/// - 5 transaksi terakhir
class MemberDashboardModel {
  /// Total nominal donasi berstatus VERIFIED.
  final double totalDonation;

  /// Jumlah transaksi berstatus VERIFIED.
  final int paymentCount;

  /// Status pembayaran bulan berjalan: "VERIFIED", "PENDING", "REJECTED",
  /// atau "UNPAID" (jika belum ada pembayaran bulan ini).
  final String currentMonth;

  /// Daftar 5 transaksi terakhir.
  final List<PaymentModel> recentTransactions;

  MemberDashboardModel({
    required this.totalDonation,
    required this.paymentCount,
    required this.currentMonth,
    required this.recentTransactions,
  });

  factory MemberDashboardModel.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['recent_transactions'];
    final List<PaymentModel> transactions = (rawTransactions is List)
        ? rawTransactions
            .map((item) => PaymentModel.fromJson(item as Map<String, dynamic>))
            .toList()
        : [];

    return MemberDashboardModel(
      totalDonation: (json['total_donation'] is String)
          ? double.parse(json['total_donation'])
          : (json['total_donation'] as num? ?? 0).toDouble(),
      paymentCount: json['payment_count'] ?? 0,
      currentMonth: json['current_month'] ?? 'UNPAID',
      recentTransactions: transactions,
    );
  }

  /// Apakah member sudah membayar bulan ini (berstatus VERIFIED).
  bool get isPaidThisMonth => currentMonth == 'VERIFIED';

  /// Apakah pembayaran bulan ini masih menunggu verifikasi.
  bool get isPendingThisMonth => currentMonth == 'PENDING';

  /// Apakah member belum membayar bulan ini sama sekali.
  bool get isUnpaidThisMonth => currentMonth == 'UNPAID';
}

// ─────────────────────────────────────────────────────────────────────────────

/// Model untuk response GET /dashboard/admin.
///
/// Berisi ringkasan kondisi kas komunitas:
/// - Saldo kas saat ini
/// - Total pemasukan & pengeluaran
/// - Jumlah pembayaran pending
/// - Jumlah member aktif
class AdminDashboardModel {
  /// Saldo kas saat ini (income − expense).
  final double cash;

  /// Total seluruh donasi yang sudah diverifikasi.
  final double income;

  /// Total seluruh pencairan dana.
  final double expense;

  /// Jumlah pembayaran yang masih berstatus PENDING.
  final int pendingPayment;

  /// Jumlah member (role = Member) yang aktif.
  final int member;

  AdminDashboardModel({
    required this.cash,
    required this.income,
    required this.expense,
    required this.pendingPayment,
    required this.member,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      cash: (json['cash'] is String)
          ? double.parse(json['cash'])
          : (json['cash'] as num? ?? 0).toDouble(),
      income: (json['income'] is String)
          ? double.parse(json['income'])
          : (json['income'] as num? ?? 0).toDouble(),
      expense: (json['expense'] is String)
          ? double.parse(json['expense'])
          : (json['expense'] as num? ?? 0).toDouble(),
      pendingPayment: json['pending_payment'] ?? 0,
      member: json['member'] ?? 0,
    );
  }

  /// Persentase pengeluaran terhadap total pemasukan (0.0 – 1.0).
  double get expenseRatio => income > 0 ? expense / income : 0.0;

  /// Apakah ada pembayaran yang perlu diverifikasi.
  bool get hasPendingPayments => pendingPayment > 0;
}
