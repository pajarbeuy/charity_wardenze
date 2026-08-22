import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/screens/member_dashboard_screen.dart';

import '../fixtures/dashboard_fixture.dart';
import '../fixtures/user_fixture.dart';
import '../helpers/pump_app.dart';
import '../mocks/mock_repositories.dart';

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockCfmsRepository mockCfmsRepo;
  late AuthProvider authProvider;
  late CfmsProvider cfmsProvider;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockCfmsRepo = MockCfmsRepository();

    authProvider = AuthProvider(authRepository: mockAuthRepo);
    cfmsProvider = CfmsProvider(repository: mockCfmsRepo);

    authProvider.setUserAndToken(UserModel.fromJson(userMemberJson), 'fake-token-xyz');
    cfmsProvider.updateToken('fake-token-xyz');
  });

  testWidgets('menampilkan ringkasan donasi member & tombol bayar donasi', (tester) async {
    when(() => mockCfmsRepo.fetchMemberDashboard('fake-token-xyz'))
        .thenAnswer((_) async => memberDashboardJson);
    when(() => mockCfmsRepo.fetchPayments('fake-token-xyz'))
        .thenAnswer((_) async => []);

    await pumpTestApp(
      tester,
      child: const MemberDashboardScreen(),
      authProvider: authProvider,
      cfmsProvider: cfmsProvider,
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard Donasi'), findsOneWidget);
    expect(find.text('BAYAR DONASI'), findsOneWidget);
    expect(find.text('RIWAYAT'), findsOneWidget);
    expect(find.text('Rp 150.000'), findsOneWidget);
  });
}
