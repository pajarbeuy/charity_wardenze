import 'package:flutter/material.dart';
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
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password baru tidak cocok'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService().patch('/profile/password', {
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: const Icon(Icons.person, size: 36, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(user?.email ?? '', style: const TextStyle(color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(user?.roleName ?? '', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Change Password Card
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
                        onPressed: _isLoading ? null : _changePassword,
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('UBAH PASSWORD'),
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
