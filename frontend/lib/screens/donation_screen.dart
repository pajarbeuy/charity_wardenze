import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/cfms_provider.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _amountController = TextEditingController(text: '10000');
  String _allocationType = 'DONATION';
  XFile? _proofXFile;
  Uint8List? _proofBytes;
  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _proofXFile = picked;
        _proofBytes = bytes;
      });
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal donasi adalah Rp10.000'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    if (_proofBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajib mengunggah bukti pembayaran'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cfms = Provider.of<CfmsProvider>(context, listen: false);
      final payment = await cfms.createPayment(amount, _allocationType);
      await cfms.uploadProof(
        payment.id,
        _proofXFile?.path,
        bytes: _proofBytes,
        filename: _proofXFile?.name ?? 'proof.jpg',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donasi berhasil dikirim! Menunggu verifikasi admin.'), backgroundColor: AppTheme.secondary),
        );
        Navigator.pop(context);
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
    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    final isOverpayment = amount > 10000;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran Donasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nominal Pembayaran (Min Rp10.000)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '10000',
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Overpayment Allocation Picker (BR-004)
            if (isOverpayment)
              Card(
                color: AppTheme.primary.withAlpha(12),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Kelebihan Pembayaran (${currencyFormat.format(amount - 10000)})',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        title: const Text('Donasi Tambahan Bulan Ini'),
                        subtitle: const Text('Kelebihan dialokasikan sebagai donasi sukarela'),
                        value: 'DONATION',
                        groupValue: _allocationType,
                        onChanged: (v) => setState(() => _allocationType = v!),
                      ),
                      RadioListTile<String>(
                        title: const Text('Bayar Bulan Berikutnya'),
                        subtitle: const Text('Kelebihan dialokasikan untuk iuran bulan mendatang'),
                        value: 'NEXT_MONTH',
                        groupValue: _allocationType,
                        onChanged: (v) => setState(() => _allocationType = v!),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Static QRIS Merchant Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('QRIS Merchant Statis', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Scan QRIS menggunakan E-Wallet atau M-Banking Anda', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.qr_code_2, size: 160, color: AppTheme.textPrimary),
                            SizedBox(height: 8),
                            Text('NPM: ID1029384756', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Komunitas Kas Donasi', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Upload Proof Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unggah Bukti Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFF8FAFC),
                        ),
                        child: _proofBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(_proofBytes!, fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF94A3B8)),
                                  SizedBox(height: 8),
                                  Text('Pilih Gambar Bukti Transfer', style: TextStyle(color: Color(0xFF475569))),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('KIRIM DONASI'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
