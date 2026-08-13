class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? avatarUrl;
  final String roleName;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.avatarUrl,
    required this.roleName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      avatarUrl: json['avatar_url'],
      roleName: json['role'] != null ? json['role']['name'] ?? 'Member' : 'Member',
    );
  }

  bool get isAdmin => roleName == 'Admin';
}
