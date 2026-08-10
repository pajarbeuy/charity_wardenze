import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final res = await ApiService(token: token).get('/reports/pdf');
      setState(() => _reportData = res['data']);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.danger));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _reportData?['summary'];
    final donations = _reportData?['donations'] as List? ?? [];
    final withdrawals = _reportData?['withdrawals'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan Kas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  Card(
                    color: AppTheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ringkasan Periode Laporan', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Pemasukan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text(currencyFormat.format(summary?['total_income'] ?? 0), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Total Pengeluaran', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text(currencyFormat.format(summary?['total_expense'] ?? 0), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Rincian Pemasukan Donasi (${donations.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: donations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => Card(
                      child: ListTile(
                        title: Text(donations[i]['member'] ?? 'Member', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tanggal: ${donations[i]['date']}'),
                        trailing: Text(currencyFormat.format(donations[i]['amount']), style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Rincian Pengeluaran Santunan (${withdrawals.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: withdrawals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => Card(
                      child: ListTile(
                        title: Text(withdrawals[i]['description'] ?? 'Santunan', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tanggal: ${withdrawals[i]['date']}'),
                        trailing: Text(currencyFormat.format(withdrawals[i]['amount']), style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
