import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _monthlyFeeCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _orgNameCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cfms = Provider.of<CfmsProvider>(context, listen: false);
      await cfms.fetchSettings();
      if (cfms.settings != null) {
        _monthlyFeeCtrl.text = cfms.settings!.monthlyFee.toStringAsFixed(0);
        _targetCtrl.text = cfms.settings!.targetPerChild.toStringAsFixed(0);
        _orgNameCtrl.text = cfms.settings!.organizationName ?? '';
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final token=Provider.of<AuthProvider>(context, listen: false).token;
      await ApiService(token:token).put('/settings', {
        'monthly_fee': double.parse(_monthlyFeeCtrl.text),
        'target_per_child': double.parse(_targetCtrl.text),
        'organization_name': _orgNameCtrl.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan berhasil diperbarui!'), backgroundColor: AppTheme.secondary),
        );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Sistem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Parameter Kas Komunitas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  controller: _monthlyFeeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minimal Iuran Bulanan (Rp)', prefixText: 'Rp '),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _targetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target Santunan Per Anak (Rp)', prefixText: 'Rp '),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _orgNameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Komunitas / Organisasi'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN PENGATURAN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
