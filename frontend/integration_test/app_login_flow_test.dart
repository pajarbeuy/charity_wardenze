import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/screens/login_screen.dart';

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
  });

  testWidgets('End-to-End App Flow: Login Member -> View Dashboard -> Logout', (WidgetTester tester) async {
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

    // 1. Berada di LoginScreen
    expect(find.byKey(const Key('emailField')), findsOneWidget);

    // 2. Isi Form Login
    await tester.enterText(find.byKey(const Key('emailField')), 'budi@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password123');

    // 3. Tap Tombol Masuk
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    // 4. Verifikasi Berhasil Masuk ke Member Dashboard
    expect(authProvider.isAuthenticated, true);
    expect(authProvider.user?.name, 'Budi Member');

    // 5. Simulasi Logout
    await authProvider.logout();
    await tester.pumpAndSettle();

    expect(authProvider.isAuthenticated, false);
  });
}
