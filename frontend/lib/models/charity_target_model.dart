/// Model untuk response GET /charity-target.
///
/// Menghitung jumlah anak yatim yang dapat disantuni berdasarkan:
///   Jumlah Anak = Saldo Kas / Target Santunan Per Anak
///
/// Contoh: Saldo Rp5.600.000 / Target Rp70.000 = 80 Anak
class CharityTargetModel {
  /// Saldo kas saat ini (total income − total expense).
  final double cash;

  /// Target santunan per anak (diambil dari settings).
  final double targetPerChild;

  /// Jumlah anak yang dapat disantuni (hasil floor(cash / targetPerChild)).
  final int children;

  CharityTargetModel({
    required this.cash,
    required this.targetPerChild,
    required this.children,
  });

  factory CharityTargetModel.fromJson(Map<String, dynamic> json) {
    return CharityTargetModel(
      cash: (json['cash'] is String)
          ? double.parse(json['cash'])
          : (json['cash'] as num).toDouble(),
      targetPerChild: (json['target_per_child'] is String)
          ? double.parse(json['target_per_child'])
          : (json['target_per_child'] as num).toDouble(),
      children: json['children'] ?? 0,
    );
  }

  /// Apakah saldo cukup untuk menyantuni setidaknya 1 anak.
  bool get canAffordAtLeastOne => children > 0;

  /// Sisa saldo setelah pembulatan (tidak digunakan untuk santunan).
  double get remainingCash => targetPerChild > 0 ? cash % targetPerChild : cash;
}
