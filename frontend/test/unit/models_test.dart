import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/payment_model.dart';
import '../fixtures/user_fixture.dart';
import '../fixtures/payment_fixture.dart';

void main() {
  group('UserModel', () {
    test('fromJson deserializes member user correctly', () {
      final user = UserModel.fromJson(userMemberJson);

      expect(user.id, 1);
      expect(user.name, 'Budi Member');
      expect(user.email, 'budi@example.com');
      expect(user.roleName, 'Member');
      expect(user.isAdmin, false);
    });

    test('fromJson deserializes admin user correctly', () {
      final user = UserModel.fromJson(userAdminJson);

      expect(user.id, 2);
      expect(user.name, 'Admin Wardenze');
      expect(user.email, 'admin@example.com');
      expect(user.roleName, 'Admin');
      expect(user.isAdmin, true);
    });
  });

  group('PaymentModel', () {
    test('fromJson deserializes payment correctly', () {
      final payment = PaymentModel.fromJson(paymentJson);

      expect(payment.id, 101);
      expect(payment.amount, 30000.0);
      expect(payment.paymentStatus, 'VERIFIED');
      expect(payment.user?.name, 'Budi Member');
    });

    test('deserializes pending payment status', () {
      final payment = PaymentModel.fromJson(paymentPendingJson);

      expect(payment.paymentStatus, 'PENDING');
    });
  });
}
