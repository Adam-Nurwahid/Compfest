import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../dummy/dummy_data.dart';

class TransactionRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Helper untuk mengecek apakah ID merupakan UUID valid atau ID lokal dummy
  bool _isValidUuid(String id) {
    final regExp = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return regExp.hasMatch(id);
  }

  // Public wrapper for UUID check
  bool isValidUuid(String id) => _isValidUuid(id);

  // --- WALLET OPERATIONS ---
  Future<int> getWalletBalance(String userId) async {
    if (!_isValidUuid(userId)) return 10000000; // Saldo default Rp 10.000.000 untuk data dummy
    try {
      final response = await _supabaseClient
          .from('wallets') // Sesuai dengan skema tabel wallets
          .select('balance')
          .eq('buyer_id', userId) // Sesuai key buyer_id
          .maybeSingle();
      return (response?['balance'] as num?)?.toInt() ?? 0;
    } catch (e) {
      print('Error getWalletBalance: $e');
      return 0;
    }
  }

  Future<void> updateWalletBalance(String userId, int newBalance, Map<String, dynamic> txLog) async {
    if (!_isValidUuid(userId)) return;
    try {
      await _supabaseClient
          .from('wallets')
          .update({'balance': newBalance})
          .eq('buyer_id', userId);

      await _supabaseClient
          .from('wallet_transactions')
          .insert({
        'buyer_id': userId,
        'amount': txLog['amount'],
        'type': txLog['type'] ?? 'payment',
      });
    } catch (e) {
      print('Error updateWalletBalance: $e');
    }
  }

  /// Persists a top-up to public.wallets and records the transaction.
  /// Uses upsert so a missing wallet row is created safely.
  Future<void> topUpWallet(String userId, int addAmount) async {
    if (!_isValidUuid(userId)) return;
    try {
      // Fetch current balance first to compute new total
      final current = await getWalletBalance(userId);
      final newBalance = current + addAmount;

      await _supabaseClient.from('wallets').upsert(
        {'buyer_id': userId, 'balance': newBalance},
        onConflict: 'buyer_id',
      );

      await _supabaseClient.from('wallet_transactions').insert({
        'buyer_id': userId,
        'amount': addAmount,
        'type': 'topup',
      });
    } catch (e) {
      print('Error topUpWallet: $e');
      // Non-fatal: local balance already updated; log only
    }
  }

  // --- ADDRESS OPERATIONS ---
  Future<List<Address>> getAddresses(String userId) async {
    if (!_isValidUuid(userId)) return [];
    try {
      final response = await _supabaseClient
          .from('addresses') // Sesuai dengan skema tabel addresses
          .select()
          .eq('buyer_id', userId); // Sesuai key buyer_id

      return (response as List).map((addr) => Address(
        id: addr['id'] as String,
        receiverName: 'Penerima Seapedia',
        phoneNumber: '08123456789',
        fullAddress: addr['address_text'] as String, // Sesuai nama kolom address_text
        isDefault: addr['is_default'] as bool,
      )).toList();
    } catch (e) {
      print('Error getAddresses: $e');
      return [];
    }
  }

  Future<void> saveAddress(String userId, Address address) async {
    if (!_isValidUuid(userId)) return;
    try {
      final data = {
        'buyer_id': userId,
        'address_text': address.fullAddress,
        'is_default': address.isDefault,
      };
      await _supabaseClient.from('addresses').insert(data);
    } catch (e) {
      print('Error saveAddress: $e');
    }
  }

  /// Updates an existing address row in public.addresses.
  /// Skips silently for non-UUID address IDs (dummy/local data).
  Future<void> updateAddress(Address address) async {
    if (!_isValidUuid(address.id)) return;
    try {
      await _supabaseClient.from('addresses').update({
        'address_text': address.fullAddress,
        'is_default': address.isDefault,
      }).eq('id', address.id);
    } catch (e) {
      print('Error updateAddress: $e');
    }
  }

  /// Deletes an address row from public.addresses by its UUID.
  /// Skips silently for non-UUID address IDs (dummy/local data).
  Future<void> deleteAddress(String addressId) async {
    if (!_isValidUuid(addressId)) return;
    try {
      await _supabaseClient.from('addresses').delete().eq('id', addressId);
    } catch (e) {
      print('Error deleteAddress: $e');
    }
  }

  // --- ORDER OPERATIONS ---
  /// Inserts an order, returns the full inserted row (with auto-generated UUID) or null for non-UUID users.
  Future<Map<String, dynamic>?> insertOrder(Map<String, dynamic> orderData) async {
    final buyerId = orderData['buyer_id'] as String? ?? '';
    if (!_isValidUuid(buyerId)) {
      debugPrint('Skipping Supabase insertOrder for non-UUID user');
      return null;
    }
    try {
      // Do NOT send 'id' — let DEFAULT gen_random_uuid() generate it
      final response = await _supabaseClient
          .from('orders')
          .insert(orderData)
          .select()
          .single();
      return response;
    } catch (e) {
      print('Error insertOrder: $e');
      rethrow;
    }
  }

  /// Inserts products into order_items table in mass bulk
  Future<void> insertOrderItems(List<Map<String, dynamic>> itemsList) async {
    if (itemsList.isEmpty) return;
    try {
      await _supabaseClient.from('order_items').insert(itemsList);
    } catch (e) {
      print('Error insertOrderItems into Supabase: $e');
      rethrow;
    }
  }

  /// Updates an order status in the orders table
  Future<void> updateOrderStatus(String orderId, String status) async {
    if (!_isValidUuid(orderId)) return;
    try {
      await _supabaseClient
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);
    } catch (e) {
      print('Error updateOrderStatus into Supabase: $e');
      rethrow;
    }
  }

  // --- DELIVERY OPERATIONS ---
  /// Persists driver assignments and calculation tracking to deliveries table
  Future<void> upsertDelivery(String orderId, String? driverId, int earnings) async {
    if (!_isValidUuid(orderId)) return;
    try {
      await _supabaseClient.from('deliveries').upsert({
        'order_id': orderId,
        if (driverId != null) 'driver_id': driverId,
        'earnings': earnings,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'order_id');
    } catch (e) {
      print('Error upsertDelivery into Supabase: $e');
      rethrow;
    }
  }

  /// Updates the stock of a product in public.products.
  /// Skips silently for non-UUID product IDs (dummy/local data).
  Future<void> updateProductStock(String productId, int newStock) async {
    if (!_isValidUuid(productId)) return;
    try {
      await _supabaseClient
          .from('products')
          .update({'stock': newStock})
          .eq('id', productId);
    } catch (e) {
      print('Error updateProductStock: $e');
      // Non-fatal: log but do not rethrow to avoid blocking checkout
    }
  }

  Future<Store?> getStoreBySellerId(String userId) async {
    if (!_isValidUuid(userId)) {
      try {
        return dummyStores.firstWhere((s) => s.sellerId == userId);
      } catch (_) {
        return null;
      }
    }
    try {
      final response = await _supabaseClient
          .from('stores')
          .select()
          .eq('seller_id', userId)
          .maybeSingle();
      if (response != null) {
        return Store(
          id: response['id'] as String,
          sellerId: response['seller_id'] as String,
          name: response['name'] as String,
          location: response['location'] as String? ?? '',
          logoUrl: response['logo_url'] as String? ?? '',
          rating: (response['rating'] as num?)?.toDouble() ?? 0.0,
          description: response['description'] as String? ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error getStoreByOwnerId: $e');
      return null;
    }
  }

  Future<List<Product>> getProductsByStoreId(String storeId) async {
    if (!_isValidUuid(storeId)) {
      return dummyProducts.where((p) => p.storeId == storeId).toList();
    }
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .eq('store_id', storeId);
      return (response as List).map((p) => Product(
        id: p['id'] as String,
        storeId: p['store_id'] as String,
        name: p['name'] as String,
        price: (p['price'] as num).toInt(),
        stock: (p['stock'] as num).toInt(),
        description: p['description'] as String? ?? '',
        imageUrl: p['image_url'] as String? ?? '',
        category: p['category'] as String? ?? '',
        rating: (p['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: (p['review_count'] as num?)?.toInt() ?? 0,
      )).toList();
    } catch (e) {
      print('Error getProductsByStoreId: $e');
      return [];
    }
  }

  Future<List<Order>> fetchOrdersByRole(String userId, String role) async {
    if (!_isValidUuid(userId)) return [];
    try {
      PostgrestFilterBuilder query = _supabaseClient.from('orders').select('''
        *,
        stores (*),
        order_items (*, products (*)),
        order_status_history (*),
        deliveries (*)
      ''');

      if (role.toLowerCase() == 'buyer') {
        query = query.eq('buyer_id', userId);
      } else if (role.toLowerCase() == 'seller') {
        // FIXED: Dapatkan UUID store milik seller terlebih dahulu sebelum mencocokkan store_id pesanan
        final storeRes = await _supabaseClient
            .from('stores')
            .select('id')
            .eq('seller_id', userId)
            .maybeSingle();

        if (storeRes != null) {
          final realStoreId = storeRes['id'] as String;
          query = query.eq('store_id', realStoreId);
        } else {
          return [];
        }
      } else if (role.toLowerCase() == 'driver') {
        final deliveryRes = await _supabaseClient
            .from('deliveries')
            .select('order_id')
            .eq('driver_id', userId);
        final orderIds = (deliveryRes as List).map((d) => d['order_id'] as String).toList();
        if (orderIds.isEmpty) return [];
        query = query.inFilter('id', orderIds);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List).map((o) => Order.fromJson(o)).toList();
    } catch (e) {
      print('Error fetchOrdersByRole: $e');
      return [];
    }
  }
}