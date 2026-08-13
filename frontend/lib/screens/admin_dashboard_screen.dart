import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/screens/audit_log_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/monthly_income_screen.dart';
import 'package:frontend/screens/monthly_status_screen.dart';
import 'package:frontend/screens/notifications_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/reports_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:frontend/screens/user_management_screen.dart';
import 'package:frontend/screens/verification_screen.dart';
import 'package:frontend/screens/withdrawal_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final cfms = Provider.of<CfmsProvider>(context, listen: false);
      cfms.updateToken(auth.token);
      cfms.fetchAdminDashboard();
      cfms.fetchCharityTarget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cfms = Provider.of<CfmsProvider>(context);
    final data = cfms.adminDashboard;
    final target = cfms.charityTarget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Kas Donasi'),
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
        onRefresh: () async {
          await cfms.fetchAdminDashboard();
          await cfms.fetchCharityTarget();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Keuangan Kas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // KPI Cards Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _kpiCard('Saldo Kas Saat Ini', currencyFormat.format(data?['cash'] ?? 0), Icons.account_balance_wallet, AppTheme.primary),
                  _kpiCard('Total Kas Masuk', currencyFormat.format(data?['income'] ?? 0), Icons.arrow_downward, AppTheme.secondary),
                  _kpiCard('Total Pengeluaran', currencyFormat.format(data?['expense'] ?? 0), Icons.arrow_upward, AppTheme.danger),
                  _kpiCard('Pembayaran Pending', '${data?['pending_payment'] ?? 0} Transaksi', Icons.hourglass_empty, AppTheme.accent),
                ],
              ),
              const SizedBox(height: 20),

              // Orphan Children Calculator Card (BR-011)
              Card(
                color: const Color(0xFF312E81),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.child_care, color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Target Santunan Anak Yatim',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${target?['children'] ?? 0} Anak Yatim',
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Target: ${currencyFormat.format(target?['target_per_child'] ?? 70000)} / Anak',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Menu Admin',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Action Menu Grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _menuItem(context, 'Verifikasi', Icons.fact_check, AppTheme.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationScreen()))),
                  _menuItem(context, 'Pencairan', Icons.payments, AppTheme.danger, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawalScreen()))),
                  _menuItem(context, 'Anggota', Icons.people, AppTheme.secondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen()))),
                  _menuItem(context, 'Status Bulan', Icons.how_to_reg, const Color(0xFF0EA5E9), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthlyStatusScreen()))),
                  _menuItem(context, 'Rekap Pendapatan', Icons.bar_chart, const Color(0xFF8B5CF6), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthlyIncomeScreen()))),
                  _menuItem(context, 'Laporan', Icons.picture_as_pdf, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
                  _menuItem(context, 'Pengaturan', Icons.settings, Colors.blueGrey, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                  _menuItem(context, 'Audit Log', Icons.security, Colors.brown, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen()))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(25),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
