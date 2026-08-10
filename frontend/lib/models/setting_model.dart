class SettingModel {
  final int id;
  final double monthlyFee;
  final double targetPerChild;
  final String? qrisImage;
  final String? organizationName;
  final String? organizationLogo;

  SettingModel({
    required this.id,
    required this.monthlyFee,
    required this.targetPerChild,
    this.qrisImage,
    this.organizationName,
    this.organizationLogo,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      id: json['id'],
      monthlyFee: (json['monthly_fee'] is String) ? double.parse(json['monthly_fee']) : (json['monthly_fee'] as num).toDouble(),
      targetPerChild: (json['target_per_child'] is String) ? double.parse(json['target_per_child']) : (json['target_per_child'] as num).toDouble(),
      qrisImage: json['qris_image'],
      organizationName: json['organization_name'],
      organizationLogo: json['organization_logo'],
    );
  }
}
