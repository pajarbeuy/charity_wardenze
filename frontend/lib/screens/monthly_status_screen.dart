import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/cfms_provider.dart';

/// Screen: Status Pembayaran Bulanan
///
/// Admin dapat memilih bulan dan melihat siapa saja yang sudah bayar,
/// masih pending, ditolak, atau belum bayar sama sekali.
class MonthlyStatusScreen extends StatefulWidget {
  const MonthlyStatusScreen({super.key});

  @override
  State<MonthlyStatusScreen> createState() => _MonthlyStatusScreenState();
}

class _MonthlyStatusScreenState extends State<MonthlyStatusScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Bulan yang dipilih (default: bulan ini)
  late DateTime _selectedMonth;
  String _filter = 'ALL'; // ALL | VERIFIED | PENDING | UNPAID | REJECTED

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  String get _monthParam => DateFormat('yyyy-MM').format(_selectedMonth);

  Future<void> _fetchData() async {
    await Provider.of<CfmsProvider>(context, listen: false)
        .fetchMonthlyStatus(month: _monthParam);
  }

  Future<void> _pickMonth() async {
    // Tampilkan picker bulan sederhana menggunakan showDatePicker
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'Pilih Bulan',
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && mounted) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
      await _fetchData();
    }
  }

  Color _statusColor(String status) => switch (status) {
        'VERIFIED' => AppTheme.secondary,
        'PENDING'  => AppTheme.accent,
        'REJECTED' => AppTheme.danger,
        _          => const Color(0xFF94A3B8), // UNPAID abu-abu
      };

  IconData _statusIcon(String status) => switch (status) {
        'VERIFIED' => Icons.check_circle_outline,
        'PENDING'  => Icons.pending_actions,
        'REJECTED' => Icons.cancel_outlined,
        _          => Icons.radio_button_unchecked,
      };

  String _statusLabel(String status) => switch (status) {
        'VERIFIED' => 'Lunas',
        'PENDING'  => 'Menunggu',
        'REJECTED' => 'Ditolak',
        _          => 'Belum Bayar',
      };

  @override
  Widget build(BuildContext context) {
    final cfms = Provider.of<CfmsProvider>(context);
    final data = cfms.monthlyStatus;
    final summary = data?['summary'] as Map<String, dynamic>?;
    final members = (data?['members'] as List?) ?? [];

    // Filter
    final filtered = _filter == 'ALL'
        ? members
        : members.where((m) => m['status'] == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pembayaran Bulanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Pilih Bulan',
            onPressed: _pickMonth,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header: Bulan yang dipilih ──────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _pickMonth,
                          child: const Text('Ganti'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Summary Cards ───────────────────────────────────────
                    if (summary != null) ...[
                      Row(
                        children: [
                          _summaryChip(
                            'Lunas',
                            '${summary['verified']}',
                            AppTheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          _summaryChip(
                            'Pending',
                            '${summary['pending']}',
                            AppTheme.accent,
                          ),
                          const SizedBox(width: 8),
                          _summaryChip(
                            'Belum',
                            '${summary['unpaid']}',
                            const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Total income bulan ini
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.payments_outlined, color: Colors.white70, size: 20),
                            const SizedBox(width: 10),
                            const Text(
                              'Total Masuk Bulan Ini',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const Spacer(),
                            Text(
                              currencyFormat.format(summary['total_income'] ?? 0),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Filter Chip Row ─────────────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('ALL', 'Semua'),
                          _filterChip('VERIFIED', 'Lunas'),
                          _filterChip('PENDING', 'Pending'),
                          _filterChip('UNPAID', 'Belum Bayar'),
                          _filterChip('REJECTED', 'Ditolak'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      '${filtered.length} anggota',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Daftar Member ───────────────────────────────────────────────
            if (data == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline, size: 48, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      Text(
                        _filter == 'ALL'
                            ? 'Belum ada data untuk bulan ini'
                            : 'Tidak ada anggota dengan status "${_statusLabel(_filter)}"',
                        style: const TextStyle(color: Color(0xFF94A3B8)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final m = filtered[i];
                      final status = m['status'] as String;
                      final color = _statusColor(status);
                      final amount = (m['amount'] as num).toDouble();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.15),
                              child: Icon(_statusIcon(status), color: color, size: 22),
                            ),
                            title: Text(
                              m['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['email'],
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                if (status != 'UNPAID') ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    currencyFormat.format(amount),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _statusLabel(status),
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppTheme.primary.withOpacity(0.15),
        checkmarkColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: selected ? AppTheme.primary : const Color(0xFF64748B),
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
