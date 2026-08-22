import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';

Future<void> pumpTestApp(
  WidgetTester tester, {
  required Widget child,
  AuthProvider? authProvider,
  CfmsProvider? cfmsProvider,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider ?? AuthProvider(),
        ),
        ChangeNotifierProvider<CfmsProvider>.value(
          value: cfmsProvider ?? CfmsProvider(),
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    ),
  );
}
