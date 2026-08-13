import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/cfms_provider.dart';

/// Screen: Rekap Pendapatan Per Bulan (tahun berjalan)
///
/// Menampilkan bar chart sederhana dan tabel pendapatan dari
/// donasi yang terverifikasi per bulan.
class MonthlyIncomeScreen extends StatefulWidget {
  const MonthlyIncomeScreen({super.key});

  @override
  State<MonthlyIncomeScreen> createState() => _MonthlyIncomeScreenState();
}

class _MonthlyIncomeScreenState extends State<MonthlyIncomeScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static const _monthNamesFull = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CfmsProvider>(context, listen: false).fetchMonthlyIncome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cfms = Provider.of<CfmsProvider>(context);
    final income = cfms.monthlyIncome ?? {};
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    // Isi bulan 1-12, 0 jika tidak ada data
    final data = List.generate(12, (i) => income[i + 1] ?? 0.0);
    final maxVal = data.isEmpty ? 1.0 : data.reduce((a, b) => a > b ? a : b);
    final totalYear = data.fold(0.0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pendapatan $currentYear'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                Provider.of<CfmsProvider>(context, listen: false).fetchMonthlyIncome(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            Provider.of<CfmsProvider>(context, listen: false).fetchMonthlyIncome(),
        child: income.isEmpty && cfms.monthlyIncome != null
            ? const Center(
                child: Text(
                  'Belum ada data pendapatan tahun ini',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              )
            : cfms.monthlyIncome == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Total tahun ──────────────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.secondary, Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.secondary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Pendapatan Tahun Ini',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                currencyFormat.format(totalYear),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dari ${income.length} bulan yang ada data',
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Bar Chart Sederhana ──────────────────────────────
                        Text(
                          'Grafik Pendapatan $currentYear',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(12, (i) {
                              final month = i + 1;
                              final val = data[i];
                              final ratio = maxVal > 0 ? val / maxVal : 0.0;
                              final isCurrentMonth = month == currentMonth;
                              final hasData = val > 0;

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Nominal di atas bar jika ada data
                                      if (hasData)
                                        RotatedBox(
                                          quarterTurns: 3,
                                          child: Text(
                                            currencyFormat.format(val).replaceAll('Rp ', ''),
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: isCurrentMonth
                                                  ? AppTheme.primary
                                                  : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 2),
                                      // Bar
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.easeOutCubic,
                                        height: hasData ? (ratio * 140).clamp(4.0, 140.0) : 4,
                                        decoration: BoxDecoration(
                                          color: hasData
                                              ? (isCurrentMonth ? AppTheme.primary : AppTheme.secondary)
                                              : const Color(0xFFE2E8F0),
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _monthNames[month],
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: isCurrentMonth
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isCurrentMonth
                                              ? AppTheme.primary
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Tabel Detail Per Bulan ───────────────────────────
                        Text(
                          'Detail Per Bulan',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(12, (i) {
                          final month = i + 1;
                          final val = data[i];
                          final hasData = val > 0;
                          final isCurrentMonth = month == currentMonth;
                          final isFuture = month > currentMonth;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isCurrentMonth
                                  ? AppTheme.primary.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrentMonth
                                    ? AppTheme.primary.withOpacity(0.3)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Nomor bulan
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: hasData
                                        ? AppTheme.secondary.withOpacity(0.1)
                                        : const Color(0xFFF8FAFC),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$month',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: hasData
                                          ? AppTheme.secondary
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Nama bulan
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _monthNamesFull[month],
                                            style: TextStyle(
                                              fontWeight: isCurrentMonth
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          if (isCurrentMonth) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primary,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Saat ini',
                                                style: TextStyle(
                                                    color: Colors.white, fontSize: 10),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        isFuture
                                            ? 'Belum dimulai'
                                            : hasData
                                                ? 'Ada donasi masuk'
                                                : 'Tidak ada data',
                                        style: const TextStyle(
                                            fontSize: 11, color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ),
                                // Nominal
                                Text(
                                  hasData
                                      ? currencyFormat.format(val)
                                      : isFuture
                                          ? '-'
                                          : 'Rp 0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: hasData
                                        ? AppTheme.secondary
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
      ),
    );
  }
}
