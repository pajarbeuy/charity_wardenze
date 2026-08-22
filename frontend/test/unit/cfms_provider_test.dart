import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/providers/cfms_provider.dart';
import '../mocks/mock_repositories.dart';
import '../fixtures/dashboard_fixture.dart';
import '../fixtures/payment_fixture.dart';

void main() {
  late MockCfmsRepository mockRepo;
  late CfmsProvider cfmsProvider;

  setUp(() {
    mockRepo = MockCfmsRepository();
    cfmsProvider = CfmsProvider(repository: mockRepo);
    cfmsProvider.updateToken('fake-token-xyz');
  });

  group('CfmsProvider - Dashboard & Stats', () {
    test('fetchMemberDashboard memuat data ringkasan member', () async {
      when(() => mockRepo.fetchMemberDashboard('fake-token-xyz'))
          .thenAnswer((_) async => memberDashboardJson);

      await cfmsProvider.fetchMemberDashboard();

      expect(cfmsProvider.memberDashboard, isNotNull);
      expect(cfmsProvider.memberDashboard?['total_donation'], 150000.0);
      expect(cfmsProvider.memberDashboard?['current_month'], 'VERIFIED');
    });

    test('fetchAdminDashboard memuat data keuangan admin', () async {
      when(() => mockRepo.fetchAdminDashboard('fake-token-xyz'))
          .thenAnswer((_) async => adminDashboardJson);

      await cfmsProvider.fetchAdminDashboard();

      expect(cfmsProvider.adminDashboard, isNotNull);
      expect(cfmsProvider.adminDashboard?['cash'], 1000000.0);
      expect(cfmsProvider.adminDashboard?['income'], 1500000.0);
      expect(cfmsProvider.adminDashboard?['pending_payment'], 2);
    });

    test('fetchMonthlyStatus memuat rekap status bayar bulanan', () async {
      when(() => mockRepo.fetchMonthlyStatus('fake-token-xyz', '2026-08'))
          .thenAnswer((_) async => monthlyStatusJson);

      await cfmsProvider.fetchMonthlyStatus(month: '2026-08');

      expect(cfmsProvider.monthlyStatus, isNotNull);
      expect(cfmsProvider.monthlyStatus?['summary']['verified'], 2);
      expect(cfmsProvider.monthlyStatus?['summary']['unpaid'], 1);
    });
  });
}
