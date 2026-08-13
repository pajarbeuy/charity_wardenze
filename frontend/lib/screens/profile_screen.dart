import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isUploadingAvatar = false;
  bool _isLoadingPass = false;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      await auth.updateProfile(
        name: user.name,
        phone: user.phone,
        avatarBytes: bytes,
        avatarPath: kIsWeb ? null : picked.path,
        filename: picked.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: AppTheme.secondary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _deleteAvatar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Foto Profil'),
        content: const Text('Apakah Anda yakin ingin menghapus foto profil?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.deleteAvatar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil dihapus'), backgroundColor: AppTheme.secondary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPassCtrl.text.isEmpty || _currentPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field password harus diisi'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password baru tidak cocok'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    setState(() => _isLoadingPass = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      await ApiService(token: token).patch('/profile/password', {
        'current_password': _currentPassCtrl.text,
        'new_password': _newPassCtrl.text,
        'new_password_confirmation': _confirmPassCtrl.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah!'), backgroundColor: AppTheme.secondary),
        );
        _currentPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingPass = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    ImageProvider? avatarImage;
    if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(user.avatarUrl!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Card (Foto Profil, Nama, Email, No Telp, Role)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Avatar & Camera Edit Button
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primary.withOpacity(0.1),
                            backgroundImage: avatarImage,
                            child: avatarImage == null
                                ? const Icon(Icons.person, size: 56, color: AppTheme.primary)
                                : null,
                          ),
                          if (_isUploadingAvatar)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Material(
                              elevation: 2,
                              shape: const CircleBorder(),
                              color: AppTheme.primary,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // User Name & Role Badge
                    Text(
                      user?.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user?.roleName ?? '',
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // User Info Details (Email & Phone)
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 20, color: Color(0xFF64748B)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user?.email ?? '-',
                            style: const TextStyle(color: Color(0xFF334155), fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF64748B)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            (user?.phone != null && user!.phone!.isNotEmpty) ? user.phone! : 'Tidak ada no. telepon',
                            style: const TextStyle(color: Color(0xFF334155), fontSize: 14),
                          ),
                        ),
                      ],
                    ),

                    // Hapus Foto Profil Option
                    if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _isUploadingAvatar ? null : _deleteAvatar,
                        icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 18),
                        label: const Text('Hapus Foto Profil', style: TextStyle(color: AppTheme.danger)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card Ubah Password (Satu-satunya form utama)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _currentPassCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password Saat Ini'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newPassCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password Baru'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmPassCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoadingPass ? null : _changePassword,
                        child: _isLoadingPass
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('UBAH PASSWORD'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
