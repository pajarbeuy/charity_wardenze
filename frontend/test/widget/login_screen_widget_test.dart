import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/login_screen.dart';

import '../helpers/pump_app.dart';
import '../mocks/mock_repositories.dart';

void main() {
  late MockAuthRepository mockAuthRepo;
  late AuthProvider authProvider;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    authProvider = AuthProvider(authRepository: mockAuthRepo);
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('menampilkan elemen form login dengan benar', (tester) async {
      await pumpTestApp(
        tester,
        child: const LoginScreen(),
        authProvider: authProvider,
      );

      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      expect(find.text('MASUK'), findsOneWidget);
    });

    testWidgets('menampilkan pesan validasi saat form kosong di-submit', (tester) async {
      await pumpTestApp(
        tester,
        child: const LoginScreen(),
        authProvider: authProvider,
      );

      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    testWidgets('menampilkan popup dialog "Server Tidak Tersedia" saat jaringan mati / Server Down', (tester) async {
      when(() => mockAuthRepo.login('budi@example.com', 'password123'))
          .thenThrow(const SocketException('Connection refused'));

      await pumpTestApp(
        tester,
        child: const LoginScreen(),
        authProvider: authProvider,
      );

      await tester.enterText(find.byKey(const Key('emailField')), 'budi@example.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verifikasi Popup Server Down muncul
      expect(find.text('Server Tidak Tersedia'), findsOneWidget);
      expect(find.text('Hubungi Admin'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('menampilkan popup dialog "Login Gagal" saat kredensial salah (401)', (tester) async {
      when(() => mockAuthRepo.login('budi@example.com', 'wrongpass'))
          .thenThrow(Exception('Invalid credentials'));

      await pumpTestApp(
        tester,
        child: const LoginScreen(),
        authProvider: authProvider,
      );

      await tester.enterText(find.byKey(const Key('emailField')), 'budi@example.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'wrongpass');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verifikasi Popup Login Failed muncul
      expect(find.text('Login Gagal'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });
  });
}
