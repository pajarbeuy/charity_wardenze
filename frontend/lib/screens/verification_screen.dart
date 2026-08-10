import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';

// ── Secure image loader: fetch bytes with Bearer token (Flutter Web compatible)
class _AuthImage extends StatefulWidget {
  final String url;
  final String? token;
  const _AuthImage({required this.url, this.token});

  @override
  State<_AuthImage> createState() => _AuthImageState();
}

class _AuthImageState extends State<_AuthImage> {
  late Future<Uint8List?> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchBytes();
  }

  Future<Uint8List?> _fetchBytes() async {
    try {
      final res = await http.get(
        Uri.parse(widget.url),
        headers: {
          'Accept': 'application/json',
          if (widget.token != null) 'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (res.statusCode == 200) return res.bodyBytes;
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snap.data == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8)),
                SizedBox(height: 4),
                Text('Gagal memuat bukti',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          );
        }
        return Image.memory(snap.data!, fit: BoxFit.cover);
      },
    );
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CfmsProvider>(context, listen: false).fetchPendingPayments();
    });
  }

  void _rejectDialog(int paymentId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Pembayaran'),
        content: TextField(
          controller: reasonController,
          decoration:
              const InputDecoration(labelText: 'Alasan Penolakan'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('BATAL')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              await Provider.of<CfmsProvider>(context, listen: false)
                  .rejectPayment(paymentId, reasonController.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('TOLAK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfms = Provider.of<CfmsProvider>(context);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Pembayaran')),
      body: RefreshIndicator(
        onRefresh: () => cfms.fetchPendingPayments(),
        child: cfms.pendingPayments.isEmpty
            ? const Center(
                child: Text('Tidak ada pembayaran pending',
                    style: TextStyle(color: Color(0xFF94A3B8))))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cfms.pendingPayments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = cfms.pendingPayments[index];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: nama & nominal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.user?.name ?? 'Member',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(currencyFormat.format(p.amount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.primary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bulan: ${p.paymentMonth} | Tipe: ${p.allocationType}',
                            style: const TextStyle(
                                color: Color(0xFF475569), fontSize: 13),
                          ),
                          const SizedBox(height: 12),

                          // Bukti pembayaran
                          if (p.proofImage != null)
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF1F5F9),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _AuthImage(
                                    url: p.proofImage!, token: token),
                              ),
                            )
                          else
                            const Text('Belum ada foto bukti',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontStyle: FontStyle.italic)),

                          const SizedBox(height: 16),

                          // Tombol aksi
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _rejectDialog(p.id),
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.danger),
                                  child: const Text('TOLAK'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await cfms.verifyPayment(p.id, 'Sesuai');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Pembayaran berhasil diverifikasi!'),
                                        backgroundColor: AppTheme.secondary,
                                      ));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.secondary),
                                  child: const Text('APPROVE'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
