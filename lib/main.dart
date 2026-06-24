import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_router.dart';
import 'data/dummy/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SEAPEDIA',
      theme: AppTheme.light,
      themeMode: ThemeMode.light, // Locked to light theme for brand consistency in demo
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
