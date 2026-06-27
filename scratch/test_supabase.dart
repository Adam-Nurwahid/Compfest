import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('Initializing Supabase...');
  await Supabase.initialize(
    url: 'https://uhmlrzoahlkbzisgxcst.supabase.co/',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVobWxyem9haGxrYnppc2d4Y3N0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyMDg1NjMsImV4cCI6MjA5Nzc4NDU2M30.wIOjT-VDuKathQ8GMSrmAKXfFQ6jT0aoZczktZ4HLSI',
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
}
