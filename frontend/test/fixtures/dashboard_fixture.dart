final Map<String, dynamic> memberDashboardJson = {
  'total_donation': 150000.0,
  'payment_count': 3,
  'current_month': 'VERIFIED',
};

final Map<String, dynamic> adminDashboardJson = {
  'cash': 1000000.0,
  'income': 1500000.0,
  'expense': 500000.0,
  'pending_payment': 2,
  'member': 19,
};

final Map<String, dynamic> charityTargetJson = {
  'cash': 1000000.0,
  'target_per_child': 70000.0,
  'children': 14,
};

final Map<String, dynamic> monthlyStatusJson = {
  'month': '2026-08',
  'summary': {
    'total': 4,
    'verified': 2,
    'pending': 1,
    'unpaid': 1,
    'rejected': 0,
    'total_income': 500000.0,
  },
  'members': [
    {
      'id': 1,
      'name': 'Budi Member',
      'email': 'budi@example.com',
      'status': 'VERIFIED',
      'amount': 250000.0,
      'payment_id': 101,
    },
    {
      'id': 2,
      'name': 'Siti Rahma',
      'email': 'siti@example.com',
      'status': 'PENDING',
      'amount': 100000.0,
      'payment_id': 102,
    },
    {
      'id': 3,
      'name': 'Agus Setiawan',
      'email': 'agus@example.com',
      'status': 'UNPAID',
      'amount': 0.0,
      'payment_id': null,
    }
  ]
};
