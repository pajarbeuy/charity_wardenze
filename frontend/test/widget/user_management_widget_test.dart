import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/screens/user_management_screen.dart';

import '../fixtures/user_fixture.dart';
import '../helpers/pump_app.dart';
import '../mocks/mock_repositories.dart';

void main() {
  late MockCfmsRepository mockCfmsRepo;
  late CfmsProvider cfmsProvider;

  setUp(() {
    mockCfmsRepo = MockCfmsRepository();
    cfmsProvider = CfmsProvider(repository: mockCfmsRepo);
    cfmsProvider.updateToken('fake-token-admin');
  });

  testWidgets('menampilkan list pengguna dan dialog reset password', (tester) async {
    when(() => mockCfmsRepo.fetchUsers('fake-token-admin'))
        .thenAnswer((_) async => [UserModel.fromJson(userMemberJson)]);

    await pumpTestApp(
      tester,
      child: const UserManagementScreen(),
      cfmsProvider: cfmsProvider,
    );

    await tester.pumpAndSettle();

    expect(find.text('Kelola Anggota Komunitas'), findsOneWidget);
    expect(find.text('Budi Member'), findsOneWidget);

    // Tap menu ⋮
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Reset Password'), findsOneWidget);

    // Tap Reset Password menu item
    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();

    // Verifikasi dialog reset password muncul
    expect(find.text('Password Baru'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
  });
}
