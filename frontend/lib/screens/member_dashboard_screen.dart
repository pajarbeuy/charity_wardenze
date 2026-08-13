import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/screens/donation_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/notifications_screen.dart';
import 'package:frontend/screens/payment_history_screen.dart';
import 'package:frontend/screens/profile_screen.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _monthFormat   = DateFormat('MMMM yyyy', 'id_ID');
  final _dtFormat      = DateFormat('d MMMM yyyy, HH:mm', 'id_ID');

  /// Format ISO date string → "Agustus 2026"
  String _formatMonth(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try { return _monthFormat.format(DateTime.parse(raw).toLocal()); }
    catch (_) { return raw; }
  }

  /// Format ISO datetime string → "12 Agustus 2026, 19:31"
  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try { return _dtFormat.format(DateTime.parse(raw).toLocal()); }
    catch (_) { return raw; }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final cfms = Provider.of<CfmsProvider>(context, listen: false);
      cfms.updateToken(auth.token);
      cfms.fetchMemberDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cfms = Provider.of<CfmsProvider>(context);
    final data = cfms.memberDashboard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Donasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final nav = Navigator.of(context);
              await auth.logout();
              nav.pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => cfms.fetchMemberDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Card
              Text(
                'Halo, ${auth.user?.name ?? "Member"} 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Terima kasih atas kontribusi bulanan Anda',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),

              // Highlight Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(76),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Donasi Disetujui',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Bulan Ini: ${data?['current_month'] ?? '...'}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currencyFormat.format(data?['total_donation'] ?? 0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sudah Berdonasi: ${data?['payment_count'] ?? 0} Transaksi',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('BAYAR DONASI'),
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationScreen()));
                        cfms.fetchMemberDashboard();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.history),
                      label: const Text('RIWAYAT'),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Donasi Terbaru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recent Transactions List
              if (data?['recent_transactions'] == null || (data!['recent_transactions'] as List).isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Belum ada transaksi donasi', style: TextStyle(color: Color(0xFF94A3B8))),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (data['recent_transactions'] as List).length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = data['recent_transactions'][index];
                    final status = item['payment_status'];
                    Color statusColor = AppTheme.accent;
                    if (status == 'VERIFIED') statusColor = AppTheme.secondary;
                    if (status == 'REJECTED') statusColor = AppTheme.danger;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withAlpha(38),
                          child: Icon(
                            status == 'VERIFIED' ? Icons.check_circle_outline : (status == 'REJECTED' ? Icons.cancel_outlined : Icons.pending_actions),
                            color: statusColor,
                          ),
                        ),
                        title: Text(
                          currencyFormat.format(double.parse(item['amount'].toString())),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDateTime(item['created_at']?.toString()),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            Text(
                              'Bulan: ${_formatMonth(item['payment_month']?.toString())}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(38),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
