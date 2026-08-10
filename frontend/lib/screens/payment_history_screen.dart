import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/cfms_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CfmsProvider>(context, listen: false).fetchPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cfms = Provider.of<CfmsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pembayaran Donasi')),
      body: RefreshIndicator(
        onRefresh: () => cfms.fetchPayments(),
        child: cfms.payments.isEmpty
            ? const Center(child: Text('Belum ada transaksi', style: TextStyle(color: Color(0xFF94A3B8))))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cfms.payments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final p = cfms.payments[index];
                  Color statusColor = AppTheme.accent;
                  if (p.paymentStatus == 'VERIFIED') statusColor = AppTheme.secondary;
                  if (p.paymentStatus == 'REJECTED') statusColor = AppTheme.danger;

                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.15),
                        child: Icon(
                          p.paymentStatus == 'VERIFIED'
                              ? Icons.check_circle
                              : (p.paymentStatus == 'REJECTED' ? Icons.cancel : Icons.hourglass_top),
                          color: statusColor,
                        ),
                      ),
                      title: Text(
                        currencyFormat.format(p.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Bulan: ${p.paymentMonth} | Tipe: ${p.allocationType}'),
                          if (p.rejectionReason != null)
                            Text('Alasan Tolak: ${p.rejectionReason}', style: const TextStyle(color: AppTheme.danger, fontSize: 12)),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p.paymentStatus,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
