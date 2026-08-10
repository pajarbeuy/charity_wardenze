import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/cfms_provider.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CfmsProvider>(context, listen: false).fetchWithdrawals();
    });
  }

  void _showAddDialog() {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    final dateController = TextEditingController(text: DateTime.now().toString().split(' ')[0]);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Catat Pencairan Dana Santunan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal Pencairan (Rp)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Keterangan Santunan'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('BATAL')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0 || descController.text.isEmpty) return;
              try {
                await Provider.of<CfmsProvider>(context, listen: false).createWithdrawal(amount, dateController.text, descController.text);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.danger),
                  );
                }
              }
            },
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfms = Provider.of<CfmsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pencairan Dana Santunan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Pencairan Baru'),
        backgroundColor: AppTheme.danger,
      ),
      body: RefreshIndicator(
        onRefresh: () => cfms.fetchWithdrawals(),
        child: cfms.withdrawals.isEmpty
            ? const Center(child: Text('Belum ada riwayat pencairan', style: TextStyle(color: Color(0xFF94A3B8))))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cfms.withdrawals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final w = cfms.withdrawals[index];

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFEE2E2),
                        child: Icon(Icons.arrow_upward, color: AppTheme.danger),
                      ),
                      title: Text(currencyFormat.format(w.amount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.danger)),
                      subtitle: Text('${w.description}\nTanggal: ${w.withdrawDate}'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
