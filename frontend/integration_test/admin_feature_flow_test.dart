import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/screens/admin_dashboard_screen.dart';

import '../test/fixtures/dashboard_fixture.dart';
import '../test/fixtures/user_fixture.dart';
import '../test/helpers/pump_app.dart';
import '../test/mocks/mock_repositories.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('End-to-End App Flow: Admin Dashboard -> View Monthly Status & User Management', (WidgetTester tester) async {
    when(() => mockCfmsRepo.fetchAdminDashboard('fake-token-admin'))
        .thenAnswer((_) async => adminDashboardJson);
    when(() => mockCfmsRepo.fetchCharityTarget('fake-token-admin'))
        .thenAnswer((_) async => charityTargetJson);
    when(() => mockCfmsRepo.fetchMonthlyStatus('fake-token-admin', any()))
        .thenAnswer((_) async => monthlyStatusJson);
    when(() => mockCfmsRepo.fetchUsers('fake-token-admin'))
        .thenAnswer((_) async => [UserModel.fromJson(userMemberJson)]);

    await pumpTestApp(
      tester,
      child: const AdminDashboardScreen(),
      authProvider: authProvider,
      cfmsProvider: cfmsProvider,
    );

    await tester.pumpAndSettle();

    // 1. Berada di Admin Dashboard
    expect(find.text('Admin Kas Donasi'), findsOneWidget);
    expect(find.text('Status Bulan'), findsOneWidget);

    // 2. Navigasi ke Status Bulan Ini
    await tester.tap(find.text('Status Bulan'));
    await tester.pumpAndSettle();

    expect(find.text('Status Pembayaran Bulanan'), findsOneWidget);

    // 3. Kembali ke Dashboard
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 4. Navigasi ke Kelola Anggota
    await tester.tap(find.text('Anggota'));
    await tester.pumpAndSettle();

    expect(find.text('Kelola Anggota Komunitas'), findsOneWidget);
    expect(find.text('Budi Member'), findsOneWidget);
  });
}
