import 'package:mocktail/mocktail.dart';
import 'package:frontend/repositories/auth_repository.dart';
import 'package:frontend/repositories/cfms_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockCfmsRepository extends Mock implements CfmsRepository {}
