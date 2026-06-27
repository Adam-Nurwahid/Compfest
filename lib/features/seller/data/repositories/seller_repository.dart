import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/models/models.dart';

class SellerRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // --- STORE OPERATIONS ---

  /// Fetch store by seller (owner) ID
  Future<Store?> getStoreBySellerId(String sellerId) async {
    try {
      final response = await _supabaseClient
          .from('stores')
          .select()
          .eq('seller_id', sellerId)
          .maybeSingle();

      if (response == null) return null;

      return Store(
        id: response['id'] as String,
        sellerId: response['seller_id'] as String,
        name: response['name'] as String,
        description: response['description'] as String,
        location: response['location'] as String? ?? '',
        logoUrl: response['logo_url'] as String? ?? '',
        rating: (response['rating'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print('Error in getStoreBySellerId: $e');
      rethrow;
    }
  }

  /// Create a new store
  Future<Store> createStore(Store store) async {
    try {
      final data = {
        'seller_id': store.sellerId,
        'name': store.name,
        'description': store.description,
        'location': store.location,
        'logo_url': store.logoUrl,
      };

      final response = await _supabaseClient
          .from('stores')
          .insert(data)
          .select()
          .single();

      return Store(
        id: response['id'] as String,
        sellerId: response['seller_id'] as String,
        name: response['name'] as String,
        description: response['description'] as String,
        location: response['location'] as String? ?? store.location,
        logoUrl: response['logo_url'] as String? ?? store.logoUrl,
        rating: (response['rating'] as num?)?.toDouble() ?? 5.0,
      );
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Nama Toko sudah digunakan! Silakan pilih nama lain.');
      }
      rethrow;
    } catch (e) {
      print('Error in createStore: $e');
      rethrow;
    }
  }

  /// Update an existing store
  Future<Store> updateStore(Store store) async {
    try {
      final data = {
        'name': store.name,
        'description': store.description,
        'location': store.location,
        'logo_url': store.logoUrl,
      };

      final response = await _supabaseClient
          .from('stores')
          .update(data)
          .eq('id', store.id)
          .select()
          .single();

      return Store(
        id: response['id'] as String,
        sellerId: response['seller_id'] as String,
        name: response['name'] as String,
        description: response['description'] as String,
        location: response['location'] as String? ?? store.location,
        logoUrl: response['logo_url'] as String? ?? store.logoUrl,
        rating: (response['rating'] as num?)?.toDouble() ?? 5.0,
      );
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Nama Toko sudah digunakan! Silakan pilih nama lain.');
      }
      rethrow;
    } catch (e) {
      print('Error in updateStore: $e');
      rethrow;
    }
  }

  // --- PRODUCT OPERATIONS ---

  /// Fetch all products for a specific store
  Future<List<Product>> getProductsByStoreId(String storeId) async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .eq('store_id', storeId);

      return (response as List).map((p) {
        final name = p['name'] as String;
        return Product(
          id: p['id'].toString(),
          storeId: p['store_id'] as String,
          name: name,
          price: (p['price'] as num).toInt(),
          stock: p['stock'] as int,
          description: p['description'] as String,
          imageUrl: _getImageUrlFromName(name),
          category: _getCategoryFromName(name),
          rating: 5.0,
          reviewCount: 0,
        );
      }).toList();
    } catch (e) {
      print('Error in getProductsByStoreId: $e');
      rethrow;
    }
  }

  /// Fetch all products across all stores (public catalog)
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select();

      return (response as List).map((p) {
        final name = p['name'] as String;
        return Product(
          id: p['id'].toString(),
          storeId: p['store_id'] as String,
          name: name,
          price: (p['price'] as num).toInt(),
          stock: p['stock'] as int,
          description: p['description'] as String,
          imageUrl: _getImageUrlFromName(name),
          category: _getCategoryFromName(name),
          rating: 5.0,
          reviewCount: 0,
        );
      }).toList();
    } catch (e) {
      print('Error in getAllProducts: $e');
      rethrow;
    }
  }

  /// Fetch all stores (public catalog sync helper)
  Future<List<Store>> getAllStores() async {
    try {
      final response = await _supabaseClient
          .from('stores')
          .select();

      return (response as List).map((s) {
        return Store(
          id: s['id'] as String,
          sellerId: s['seller_id'] as String,
          name: s['name'] as String,
          description: s['description'] as String,
          location: s['location'] as String? ?? '',
          logoUrl: s['logo_url'] as String? ?? '',
          rating: (s['rating'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      print('Error in getAllStores: $e');
      rethrow;
    }
  }

  /// Create a product
  Future<Product> createProduct(Product product) async {
    // Enforce check constraints client-side as well
    if (product.stock < 0) {
      throw Exception('Stok tidak boleh bernilai negatif!');
    }

    try {
      final data = {
        'store_id': product.storeId,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock,
      };

      final response = await _supabaseClient
          .from('products')
          .insert(data)
          .select()
          .single();

      return Product(
        id: response['id'].toString(),
        storeId: response['store_id'] as String,
        name: response['name'] as String,
        price: (response['price'] as num).toInt(),
        stock: response['stock'] as int,
        description: response['description'] as String,
        imageUrl: product.imageUrl,
        category: product.category,
        rating: 5.0,
        reviewCount: 0,
      );
    } catch (e) {
      print('Error in createProduct: $e');
      rethrow;
    }
  }

  /// Update an existing product
  Future<Product> updateProduct(Product product) async {
    if (product.stock < 0) {
      throw Exception('Stok tidak boleh bernilai negatif!');
    }

    try {
      final data = {
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock,
      };

      final response = await _supabaseClient
          .from('products')
          .update(data)
          .eq('id', product.id)
          .select()
          .single();

      return Product(
        id: response['id'].toString(),
        storeId: response['store_id'] as String,
        name: response['name'] as String,
        price: (response['price'] as num).toInt(),
        stock: response['stock'] as int,
        description: response['description'] as String,
        imageUrl: product.imageUrl,
        category: product.category,
        rating: 5.0,
        reviewCount: 0,
      );
    } catch (e) {
      print('Error in updateProduct: $e');
      rethrow;
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabaseClient
          .from('products')
          .delete()
          .eq('id', productId);
    } catch (e) {
      print('Error in deleteProduct: $e');
      rethrow;
    }
  }

  String _getCategoryFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('sail') || lower.contains('boat') || lower.contains('sailing') || lower.contains('helm') || lower.contains('wheel') || lower.contains('anemometer') || lower.contains('bag') || lower.contains('deck')) {
      return 'Sailing';
    }
    if (lower.contains('pancing') || lower.contains('fish') || lower.contains('reel') || lower.contains('rod') || lower.contains('hook') || lower.contains('jigging')) {
      return 'Fishing';
    }
    return 'Diving';
  }

  String _getImageUrlFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('wheel') || lower.contains('helm')) {
      return 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=500&auto=format&fit=crop';
    }
    if (lower.contains('anemometer')) {
      return 'https://images.unsplash.com/photo-1513553404607-988bf2703777?w=500&auto=format&fit=crop';
    }
    if (lower.contains('bag') || lower.contains('deck')) {
      return 'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?w=500&auto=format&fit=crop';
    }
    if (lower.contains('gloves')) {
      return 'https://images.unsplash.com/photo-1516259762381-22954d7d3ad2?w=500&auto=format&fit=crop';
    }
    if (lower.contains('reel') || lower.contains('pancing') || lower.contains('master')) {
      return 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=500&auto=format&fit=crop';
    }
    if (lower.contains('rod') || lower.contains('jigging')) {
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop';
    }
    if (lower.contains('knife')) {
      return 'https://images.unsplash.com/photo-1582201942988-13e60e4556ee?w=500&auto=format&fit=crop';
    }
    if (lower.contains('suit') || lower.contains('wet')) {
      return 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=500&auto=format&fit=crop';
    }
    if (lower.contains('mask') || lower.contains('kacamata')) {
      return 'https://images.unsplash.com/photo-1607569762195-e8524d56d4db?w=500&auto=format&fit=crop';
    }
    if (lower.contains('fin') || lower.contains('kaki katak')) {
      return 'https://images.unsplash.com/photo-1518152006812-edab29b069ac?w=500&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1530541930197-ff16ac917b0e?w=500&auto=format&fit=crop';
  }
}
