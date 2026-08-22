import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/screens/login_screen.dart';

import '../fixtures/dashboard_fixture.dart';
import '../fixtures/user_fixture.dart';
import '../helpers/pump_app.dart';
import '../mocks/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;
  late MockCfmsRepository mockCfmsRepo;
  late AuthProvider authProvider;
  late CfmsProvider cfmsProvider;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuthRepo = MockAuthRepository();
    mockCfmsRepo = MockCfmsRepository();

    authProvider = AuthProvider(authRepository: mockAuthRepo);
    cfmsProvider = CfmsProvider(repository: mockCfmsRepo);
  });

  testWidgets('App Flow Integration: Login Member -> View Dashboard -> Logout', (WidgetTester tester) async {
    when(() => mockAuthRepo.login('budi@example.com', 'password123'))
        .thenAnswer((_) async => loginSuccessResponse);
    when(() => mockAuthRepo.logout(any())).thenAnswer((_) async {});
    when(() => mockCfmsRepo.fetchMemberDashboard(any()))
        .thenAnswer((_) async => memberDashboardJson);
    when(() => mockCfmsRepo.fetchPayments(any()))
        .thenAnswer((_) async => []);

    await pumpTestApp(
      tester,
      child: const LoginScreen(),
      authProvider: authProvider,
      cfmsProvider: cfmsProvider,
    );

    // 1. Form Login Render
    expect(find.byKey(const Key('emailField')), findsOneWidget);

    // 2. Input Email & Password
    await tester.enterText(find.byKey(const Key('emailField')), 'budi@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password123');

    // 3. Submit Form
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    // 4. Verifikasi State Login & Dashboard Member
    expect(authProvider.isAuthenticated, true);
    expect(authProvider.user?.name, 'Budi Member');

    // 5. Tap Tombol Logout di Dashboard Header
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 6. Verifikasi State Logout & Kembali ke LoginScreen Form
    expect(authProvider.isAuthenticated, false);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
  });
}
