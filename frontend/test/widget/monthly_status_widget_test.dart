import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/screens/monthly_status_screen.dart';

import '../fixtures/dashboard_fixture.dart';
import '../helpers/pump_app.dart';
import '../mocks/mock_repositories.dart';

void main() {
  late MockCfmsRepository mockCfmsRepo;
  late CfmsProvider cfmsProvider;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    mockCfmsRepo = MockCfmsRepository();
    cfmsProvider = CfmsProvider(repository: mockCfmsRepo);
    cfmsProvider.updateToken('fake-token-admin');
  });

  testWidgets('menampilkan filter chip, summary, dan daftar anggota', (tester) async {
    when(() => mockCfmsRepo.fetchMonthlyStatus('fake-token-admin', any()))
        .thenAnswer((_) async => monthlyStatusJson);

    await pumpTestApp(
      tester,
      child: const MonthlyStatusScreen(),
      cfmsProvider: cfmsProvider,
    );

    await tester.pumpAndSettle();

    expect(find.text('Status Pembayaran Bulanan'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Lunas'), findsWidgets);
    expect(find.text('Pending'), findsWidgets);
    expect(find.text('Belum Bayar'), findsWidgets);

    // Data member
    expect(find.text('Budi Member'), findsOneWidget);
    expect(find.text('Siti Rahma'), findsOneWidget);
    expect(find.text('Agus Setiawan'), findsOneWidget);
  });
}
