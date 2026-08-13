import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/cfms_provider.dart';
import 'package:frontend/screens/admin_dashboard_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/member_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // Wajib sebelum pakai DateFormat locale
  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => CfmsProvider()),
      ],
      child: const CFMSApp(),
    ),
  );
}

class CFMSApp extends StatelessWidget {
  const CFMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charity Fund Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) {
            return const LoginScreen();
          }
          if (auth.isAdmin) {
            return const AdminDashboardScreen();
          }
          return const MemberDashboardScreen();
        },
      ),
    );
  }
}
