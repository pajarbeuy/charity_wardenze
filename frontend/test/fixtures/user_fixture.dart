final Map<String, dynamic> userMemberJson = {
  'id': 1,
  'role_id': 1,
  'name': 'Budi Member',
  'email': 'budi@example.com',
  'phone': '081234567890',
  'avatar': 'avatars/budi.webp',
  'created_at': '2026-08-01T10:00:00.000000Z',
  'role': {
    'id': 1,
    'name': 'Member',
  },
};

final Map<String, dynamic> userAdminJson = {
  'id': 2,
  'role_id': 2,
  'name': 'Admin Wardenze',
  'email': 'admin@example.com',
  'phone': '089876543210',
  'avatar': null,
  'created_at': '2026-08-01T10:00:00.000000Z',
  'role': {
    'id': 2,
    'name': 'Admin',
  },
};

final Map<String, dynamic> loginSuccessResponse = {
  'success': true,
  'message': 'Login Success',
  'data': {
    'token': 'fake-jwt-token-12345',
    'user': userMemberJson,
  },
};

final Map<String, dynamic> loginAdminSuccessResponse = {
  'success': true,
  'message': 'Login Success',
  'data': {
    'token': 'fake-jwt-admin-token-999',
    'user': userAdminJson,
  },
};
