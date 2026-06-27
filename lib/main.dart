import 'package:compfest/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:compfest/features/seller/data/repositories/seller_repository.dart';
import 'package:compfest/data/repositories/transaction_repository.dart';
import 'package:compfest/features/seller/presentation/bloc/seller_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'data/dummy/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi koneksi aman database produksi Supabase
  await Supabase.initialize(
    url: 'https://uhmlrzoahlkbzisgxcst.supabase.co/',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVobWxyem9haGxrYnppc2d4Y3N0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyMDg1NjMsImV4cCI6MjA5Nzc4NDU2M30.wIOjT-VDuKathQ8GMSrmAKXfFQ6jT0aoZczktZ4HLSI',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState.instance,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SellerRepository>(
          create: (context) => SellerRepository(),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (context) => TransactionRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(),
          ),
          BlocProvider(
            create: (context) => SellerBloc(
              sellerRepository: context.read<SellerRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'SEAPEDIA',
          theme: AppTheme.light,
          themeMode: ThemeMode.light,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}