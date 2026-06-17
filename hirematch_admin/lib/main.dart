import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'shared/layout/admin_shell.dart';
import 'shared/theme/app_colors.dart';

void main() {
  runApp(const HireMatchAdminApp());
}

class HireMatchAdminApp extends StatelessWidget {
  const HireMatchAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..tryAutoLogin(),
      child: MaterialApp(
        title: 'HireMatch Admin',
        debugShowCheckedModeBanner: false,
        theme: buildAdminTheme(),
        home: const _RootGate(),
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    switch (status) {
      case AuthStatus.unknown:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        return const AdminShell();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}
