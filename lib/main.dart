import 'package:compfest/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:compfest/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compfest App',
      theme: AppTheme.light,
      themeMode: ThemeMode.system,
      home: LoginPage()
    );
  }
}
