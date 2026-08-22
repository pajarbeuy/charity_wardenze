import 'user_fixture.dart';

final Map<String, dynamic> paymentJson = {
  'id': 101,
  'user_id': 1,
  'amount': '30000.00',
  'mandatory_fee': '10000.00',
  'allocation_type': 'DONATION',
  'payment_status': 'VERIFIED',
  'payment_month': '2026-08-01',
  'proof_image': 'payment-proofs/sample.webp',
  'verified_by': 2,
  'verified_at': '2026-08-02T14:30:00.000000Z',
  'rejection_reason': null,
  'created_at': '2026-08-01T12:00:00.000000Z',
  'user': userMemberJson,
  'allocations': [
    {
      'id': 1,
      'payment_id': 101,
      'user_id': 1,
      'amount': '10000.00',
      'allocation_type': 'MONTHLY',
      'allocation_month': '2026-08-01',
    },
    {
      'id': 2,
      'payment_id': 101,
      'user_id': 1,
      'amount': '20000.00',
      'allocation_type': 'DONATION',
      'allocation_month': '2026-08-01',
    }
  ]
};

final Map<String, dynamic> paymentPendingJson = {
  'id': 102,
  'user_id': 1,
  'amount': '10000.00',
  'mandatory_fee': '10000.00',
  'allocation_type': 'DONATION',
  'payment_status': 'PENDING',
  'payment_month': '2026-08-01',
  'proof_image': null,
  'verified_by': null,
  'verified_at': null,
  'rejection_reason': null,
  'created_at': '2026-08-10T12:00:00.000000Z',
  'user': userMemberJson,
  'allocations': []
};
