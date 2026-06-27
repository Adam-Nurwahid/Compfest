import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    });
  });

  test('Inspect Supabase Tables', () async {
    print('Initializing Supabase in test...');
    await Supabase.initialize(
      url: 'https://uhmlrzoahlkbzisgxcst.supabase.co/',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVobWxyem9haGxrYnppc2d4Y3N0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyMDg1NjMsImV4cCI6MjA5Nzc4NDU2M30.wIOjT-VDuKathQ8GMSrmAKXfFQ6jT0aoZczktZ4HLSI',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );
    
    final client = Supabase.instance.client;
    
    try {
      print('\n--- FETCHING PROFILES ---');
      final profiles = await client.from('profiles').select().limit(5);
      print('Profiles sample: $profiles');
    } catch (e) {
      print('Failed to fetch profiles: $e');
    }

    try {
      print('\n--- FETCHING STORES ---');
      final stores = await client.from('stores').select().limit(5);
      print('Stores sample: $stores');
    } catch (e) {
      print('Failed to fetch stores: $e');
    }

    try {
      print('\n--- FETCHING PRODUCTS ---');
      final products = await client.from('products').select().limit(5);
      print('Products sample: $products');
    } catch (e) {
      print('Failed to fetch products: $e');
    }
  });
}
