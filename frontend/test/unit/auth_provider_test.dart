import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/models/user_model.dart';
import '../mocks/mock_repositories.dart';
import '../fixtures/user_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;
  late AuthProvider authProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuthRepo = MockAuthRepository();
    authProvider = AuthProvider(authRepository: mockAuthRepo);
  });

  group('AuthProvider - login()', () {
    test('login sukses -> state terisi user dan isAuthenticated true', () async {
      when(() => mockAuthRepo.login('budi@example.com', 'password123'))
          .thenAnswer((_) async => loginSuccessResponse);

      final result = await authProvider.login('budi@example.com', 'password123');

      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.token, 'fake-jwt-token-12345');
      expect(authProvider.user?.name, 'Budi Member');
      expect(authProvider.isAdmin, false);
    });

    test('login admin -> isAdmin bernilai true', () async {
      when(() => mockAuthRepo.login('admin@example.com', 'admin123'))
          .thenAnswer((_) async => loginAdminSuccessResponse);

      final result = await authProvider.login('admin@example.com', 'admin123');

      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.isAdmin, true);
    });

    test('server down / exception -> rethrow exception dan state tetap unauthenticated', () async {
      when(() => mockAuthRepo.login(any(), any()))
          .thenThrow(Exception('Connection refused / Server down'));

      expect(
        () => authProvider.login('budi@example.com', 'password123'),
        throwsA(isA<Exception>()),
      );

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, isNull);
    });
  });

  group('AuthProvider - logout()', () {
    test('logout() mencabut token dan meriset user state', () async {
      when(() => mockAuthRepo.login('budi@example.com', 'password123'))
          .thenAnswer((_) async => loginSuccessResponse);
      when(() => mockAuthRepo.logout(any())).thenAnswer((_) async {});

      await authProvider.login('budi@example.com', 'password123');
      expect(authProvider.isAuthenticated, true);

      await authProvider.logout();

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, isNull);
      expect(authProvider.token, isNull);
    });
  });
}
