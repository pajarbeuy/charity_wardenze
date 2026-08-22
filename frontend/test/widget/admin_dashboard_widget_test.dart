import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/screens/admin_dashboard_screen.dart';

import '../fixtures/dashboard_fixture.dart';
import '../fixtures/user_fixture.dart';
import '../helpers/pump_app.dart';
import '../mocks/mock_repositories.dart';

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockCfmsRepository mockCfmsRepo;
  late AuthProvider authProvider;
  late CfmsProvider cfmsProvider;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockCfmsRepo = MockCfmsRepository();

    authProvider = AuthProvider(authRepository: mockAuthRepo);
    cfmsProvider = CfmsProvider(repository: mockCfmsRepo);

    authProvider.setUserAndToken(UserModel.fromJson(userAdminJson), 'fake-token-admin');
    cfmsProvider.updateToken('fake-token-admin');
  });

  testWidgets('menampilkan 4 KPI card, target anak yatim, dan menu admin', (tester) async {
    when(() => mockCfmsRepo.fetchAdminDashboard('fake-token-admin'))
        .thenAnswer((_) async => adminDashboardJson);
    when(() => mockCfmsRepo.fetchCharityTarget('fake-token-admin'))
        .thenAnswer((_) async => charityTargetJson);

    await pumpTestApp(
      tester,
      child: const AdminDashboardScreen(),
      authProvider: authProvider,
      cfmsProvider: cfmsProvider,
    );

    await tester.pumpAndSettle();

    expect(find.text('Admin Kas Donasi'), findsOneWidget);
    expect(find.text('Saldo Kas Saat Ini'), findsOneWidget);
    expect(find.text('Rp 1.000.000'), findsOneWidget); // Cash balance
    expect(find.text('Total Kas Masuk'), findsOneWidget);
    expect(find.text('Total Pengeluaran'), findsOneWidget);
    expect(find.text('Target Santunan Anak Yatim'), findsOneWidget);
    expect(find.text('14 Anak Yatim'), findsOneWidget);

    // Menu Admin Grid
    expect(find.text('Verifikasi'), findsOneWidget);
    expect(find.text('Pencairan'), findsOneWidget);
    expect(find.text('Anggota'), findsOneWidget);
    expect(find.text('Status Bulan'), findsOneWidget);
    expect(find.text('Rekap Pendapatan'), findsOneWidget);
  });
}
