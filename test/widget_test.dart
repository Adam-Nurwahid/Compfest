import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:compfest/main.dart';
import 'package:compfest/data/dummy/app_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    });

    // Initialize Supabase if not already initialized
    try {
      await Supabase.initialize(
        url: 'https://uhmlrzoahlkbzisgxcst.supabase.co/',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVobWxyem9haGxrYnppc2d4Y3N0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyMDg1NjMsImV4cCI6MjA5Nzc4NDU2M30.wIOjT-VDuKathQ8GMSrmAKXfFQ6jT0aoZczktZ4HLSI',
        authOptions: const FlutterAuthClientOptions(
          localStorage: EmptyLocalStorage(),
        ),
      );
    } catch (_) {}
  });

  testWidgets('SEAPEDIA App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppState.instance,
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the title SEAPEDIA is rendered in the app
    expect(find.text('SEAPEDIA'), findsWidgets);
  });
}
