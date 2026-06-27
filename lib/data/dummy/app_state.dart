import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/transaction_repository.dart';
import '../../features/app_review/data/repositories/app_review_repository.dart';
import 'dummy_data.dart';

class AppState extends ChangeNotifier {
  static AppState? _instance;
  static AppState get instance {
    _instance ??= AppState._init();
    return _instance!;
  }

  final TransactionRepository _txRepository = TransactionRepository();
  final AppReviewRepository _reviewRepository = AppReviewRepository();

  // --- STATE VARIABEL ---
  User? _currentUser;
  bool _isLoggedIn = false;
  String _activeRole = 'Guest';
  int _walletBalance = 0;
  List<Address> _addresses = [];
  List<Order> _orders = [];
  final List<CartItem> _cartItems = [];
  String? _cartStoreId;
  Store? _currentUserStore;

  bool _isDriverOnline = true;
  DateTime _simulatedDateTime = DateTime.now();
  List<WalletTransaction> _walletTransactions = [];
  List<Voucher> _vouchers = [];
  List<Promo> _promos = [];
  List<AppReview> _appReviews = [];
  List<Product> _currentStoreProducts = [];

  AppState._init() {
    _vouchers.addAll(dummyVouchers);
    _promos.addAll(dummyPromos);
    _appReviews.addAll(dummyAppReviews);
  }

  static String _formatRole(String role) {
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  // --- GETTERS ---
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String get activeRole => _activeRole;
  int get walletBalance => _walletBalance;
  List<Address> get addresses => _addresses;
  List<Order> get orders => _orders;
  List<CartItem> get cartItems => _cartItems;
  String? get cartStoreId => _cartStoreId;
  List<String> get availableRoles => _currentUser?.roles ?? [];
  bool get isDriverOnline => _isDriverOnline;
  DateTime get simulatedDateTime => _simulatedDateTime;
  List<WalletTransaction> get walletTransactions => _walletTransactions;
  List<Voucher> get vouchers => _vouchers;
  List<Promo> get promos => _promos;
  List<AppReview> get appReviews => _appReviews;
  Store? get currentUserStore => _currentUserStore;
  List<Product> get currentStoreProducts => _currentStoreProducts;

  Store? get cartStore {
    if (_cartStoreId == null) return null;
    try {
      return dummyStores.firstWhere((s) => s.id == _cartStoreId);
    } catch (_) {
      return null;
    }
  }

  int get cartSubtotal {
    return _cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  Address get defaultAddress => _addresses.firstWhere(
        (addr) => addr.isDefault,
    orElse: () => _addresses.isNotEmpty
        ? _addresses.first
        : Address(
      id: 'default',
      receiverName: 'Nama Pembeli',
      phoneNumber: '08123456789',
      fullAddress: 'Belum ada alamat disimpan',
      isDefault: true,
    ),
  );

  Store? getStoreBySellerId(String sellerId) {
    try {
      return dummyStores.firstWhere((store) => store.sellerId == sellerId);
    } catch (_) {
      return null;
    }
  }

  // --- SYNC METHODS ---
  void syncProducts(List<Product> products, String storeId) {
    dummyProducts.removeWhere((p) => p.storeId == storeId);
    dummyProducts.addAll(products);
    notifyListeners();
  }

  void syncAllProductsAndStores(List<Product> products, List<Store> stores) {
    dummyProducts.clear();
    dummyProducts.addAll(products);
    dummyStores.clear();
    dummyStores.addAll(stores);
    notifyListeners();
  }

  // --- SINKRONISASI DATA PRODUKSI ---
  Future<void> loadUserData(String userId, String role) async {
    try {
      _walletBalance = await _txRepository.getWalletBalance(userId);
      _addresses = await _txRepository.getAddresses(userId);
      _orders = await _txRepository.fetchOrdersByRole(userId, role);

      // Ambil data toko jika user memiliki akses seller
      if (_currentUser?.roles.map((r) => r.toLowerCase()).contains('seller') ?? false) {
        _currentUserStore = await _txRepository.getStoreBySellerId(userId);
        if (_currentUserStore != null) {
          _currentStoreProducts = await _txRepository.getProductsByStoreId(_currentUserStore!.id);
        }
      }

      // Load app reviews from Supabase for authenticated users
      final dbReviews = await _reviewRepository.fetchAllReviews();
      if (dbReviews.isNotEmpty) {
        _appReviews = dbReviews;
      }
      // If Supabase returned nothing (new DB / no reviews yet), keep dummyAppReviews as fallback

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading production data: $e');
    }
  }

  void setLoggedInUser(String id, String username, String email, List<String> roles, String activeRole) {
    List<String> capitalizedRoles = roles.map((r) => _formatRole(r)).toList();
    String capitalizedActiveRole = _formatRole(activeRole);

    _currentUser = User(
      id: id,
      name: username,
      email: email,
      username: username,
      password: '',
      roles: capitalizedRoles,
      activeRole: capitalizedActiveRole,
    );
    _isLoggedIn = true;
    _activeRole = capitalizedActiveRole;

    loadUserData(id, activeRole);
  }

  void addRoleLocallyAndSwitch(String newRole) {
    if (_currentUser == null) return;
    final formattedRole = _formatRole(newRole);

    List<String> updatedRoles = List.from(_currentUser!.roles);
    if (!updatedRoles.contains(formattedRole)) {
      updatedRoles.add(formattedRole);
    }

    _currentUser = _currentUser!.copyWith(
      roles: updatedRoles,
      activeRole: formattedRole,
    );
    _activeRole = formattedRole;

    loadUserData(_currentUser!.id, newRole.toLowerCase());
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _activeRole = 'Guest';
    _walletBalance = 0;
    _currentUserStore = null;
    _addresses.clear();
    _orders.clear();
    _cartItems.clear();
    _cartStoreId = null;
    _walletTransactions.clear();
    _currentStoreProducts.clear();
    notifyListeners();
  }

  void setActiveRole(String role) {
    if (_isLoggedIn && _currentUser != null) {
      _activeRole = _formatRole(role);
      loadUserData(_currentUser!.id, role.toLowerCase());
    }
  }

  // --- MANAJEMEN KERANJANG REALTIME ---
  bool addToCart(Product product, {bool forceClear = false}) {
    if (forceClear) {
      _cartItems.clear();
      _cartStoreId = product.storeId;
    }

    if (_cartItems.isEmpty) {
      _cartStoreId = product.storeId;
    } else if (_cartStoreId != product.storeId) {
      return false; // Blokir aturan single-store checkout [cite: 450, 557]
    }

    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _cartItems[index].quantity += 1;
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
    return true;
  }

  void updateCartQuantity(String productId, int change) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _cartItems[index].quantity += change;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
      if (_cartItems.isEmpty) _cartStoreId = null;
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    if (_cartItems.isEmpty) _cartStoreId = null;
    notifyListeners();
  }

  // --- ACTIONS PRODUKSI VIA REPOSITORY ---
  Future<({String? error, String? orderId})> checkoutActiveCart({
    required int ppnAmount,
    required int discountAmount,
    required Address address,
    required String deliveryMethod,
    required int deliveryFee,
    required int finalTotal,
    String? voucherCode,
  }) async {
    if (_currentUser == null) return (error: 'Pengguna belum login.', orderId: null);
    if (_cartItems.isEmpty) return (error: 'Keranjang belanja kosong.', orderId: null);
    if (_cartStoreId == null || _cartStoreId!.isEmpty) return (error: 'Data toko tidak ditemukan.', orderId: null);
    if (_walletBalance < finalTotal) return (error: 'Saldo SEA-Wallet tidak mencukupi.', orderId: null);

    // Validasi ketersediaan stok
    for (final item in _cartItems) {
      if (item.product.stock < item.quantity) {
        return (error: 'Stok "${item.product.name}" tidak mencukupi (tersedia ${item.product.stock}, diminta ${item.quantity}).', orderId: null);
      }
    }

    // Validasi kelengkapan alamat pengiriman
    final addrText = address.fullAddress.trim();
    if (addrText.isEmpty || addrText == 'Belum ada alamat disimpan') {
      return (error: 'Silakan pilih atau tambahkan alamat pengiriman terlebih dahulu.', orderId: null);
    }

    try {
      final orderData = {
        'buyer_id': _currentUser!.id,
        'store_id': _cartStoreId,
        'delivery_method': deliveryMethod,
        'delivery_fee': deliveryFee,
        'ppn_amount': ppnAmount,
        'discount_amount': discountAmount,
        'subtotal': _cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity)),
        'final_total': finalTotal,
        'status': 'Sedang Dikemas',
        'shipping_address': address.fullAddress,
      };

      // Deduct stock once and sync to DB in a single pass (fixes double-deduction bug)
      for (final item in _cartItems) {
        item.product.stock -= item.quantity;
        await _txRepository.updateProductStock(item.product.id, item.product.stock);
      }
      // Pengurangan kuota voucher lokal jika dipakai
      if (voucherCode != null) {
        final vIdx = _vouchers.indexWhere((v) => v.code == voucherCode);
        if (vIdx != -1 && _vouchers[vIdx].quotaRemaining > 0) {
          _vouchers[vIdx].quotaRemaining--;
        }
      }

      // 1. Simpan induk pesanan ke Supabase
      final inserted = await _txRepository.insertOrder(orderData);

      final orderId = inserted != null ? inserted['id'] as String : 'dummy-${DateTime.now().millisecondsSinceEpoch}';
      if (inserted != null) {
        final List<Map<String, dynamic>> itemsPayload = _cartItems.map((item) => {
          'order_id': orderId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'price_at_purchase': item.product.price,
        }).toList();

        await _txRepository.insertOrderItems(itemsPayload);
      }

      final newBalance = _walletBalance - finalTotal;
      await _txRepository.updateWalletBalance(_currentUser!.id, newBalance, {
        'user_id': _currentUser!.id,
        'type': 'payment',
        'amount': finalTotal,
        'title': 'Pembayaran Transaksi $orderId',
      });

      _walletBalance = newBalance;
      _cartItems.clear();
      _cartStoreId = null;

      await loadUserData(_currentUser!.id, _activeRole);
      return (error: null, orderId: orderId);
    } catch (e) {
      debugPrint('Checkout failed: $e');
      return (error: 'Gagal memproses pesanan: ${e.toString().replaceAll('Exception:', '').trim()}', orderId: null);
    }
  }

  Future<void> refreshStoreData() async {
    if (_currentUser != null && (_currentUser?.roles.map((r) => r.toLowerCase()).contains('seller') ?? false)) {
      _currentUserStore = await _txRepository.getStoreBySellerId(_currentUser!.id);
      if (_currentUserStore != null) {
        _currentStoreProducts = await _txRepository.getProductsByStoreId(_currentUserStore!.id);
      }
      notifyListeners();
    }
  }


  void clearCart() {
    _cartItems.clear();
    _cartStoreId = null;
    notifyListeners();
  }

  void triggerRefresh() {
    notifyListeners();
  }

  // --- WALLET & TOPUP ---
  void topUp(int amount) {
    if (amount <= 0) return;
    _walletBalance += amount;
    _walletTransactions.insert(
      0,
      WalletTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: 'topup',
        amount: amount,
        timestamp: DateTime.now(),
        title: 'Top Up Saldo',
      ),
    );
    notifyListeners();

    // Persist to Supabase (fire-and-forget; non-fatal if fails for dummy users)
    if (_currentUser != null) {
      _txRepository.topUpWallet(_currentUser!.id, amount);
    }
  }

  // --- ADDRESS WORKFLOW ---
  void addAddress(Address address) {
    if (address.isDefault) {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    _addresses.add(address);
    notifyListeners();
  }

  void editAddress(Address updatedAddress) {
    final index = _addresses.indexWhere((addr) => addr.id == updatedAddress.id);
    if (index != -1) {
      if (updatedAddress.isDefault) {
        for (int i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }
      _addresses[index] = updatedAddress;
      notifyListeners();
      // Persist change to Supabase (fire-and-forget; skips non-UUID IDs)
      _txRepository.updateAddress(updatedAddress);
    }
  }

  void deleteAddress(String addressId) {
    final index = _addresses.indexWhere((addr) => addr.id == addressId);
    if (index != -1) {
      final wasDefault = _addresses[index].isDefault;
      _addresses.removeAt(index);
      if (wasDefault && _addresses.isNotEmpty) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }
      notifyListeners();
      // Persist deletion to Supabase (fire-and-forget; skips non-UUID IDs)
      _txRepository.deleteAddress(addressId);
    }
  }

  void setDefaultAddress(String addressId) {
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].id == addressId) {
        _addresses[i] = _addresses[i].copyWith(isDefault: true);
      } else {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
    notifyListeners();
  }

  // --- VOUCHER & PROMO VALIDATION ---
  void addVoucher(Voucher voucher) {
    _vouchers.add(voucher);
    notifyListeners();
  }

  void addPromo(Promo promo) {
    _promos.add(promo);
    notifyListeners();
  }

  Map<String, dynamic> validateVoucher(String code, int subtotal) {
    final normalizedCode = code.toUpperCase().trim();
    final index = _vouchers.indexWhere((v) => v.code == normalizedCode);
    if (index == -1) return {'valid': false, 'message': 'Kode Voucher tidak ditemukan.', 'discount': 0};
    final v = _vouchers[index];

    // Guard 1: Check expiry date
    if (v.expiryDate.isBefore(DateTime.now())) {
      return {'valid': false, 'message': 'Voucher "${v.code}" sudah kedaluwarsa.', 'discount': 0};
    }
    // Guard 2: Check remaining quota
    if (v.quotaRemaining <= 0) {
      return {'valid': false, 'message': 'Kuota Voucher "${v.code}" telah habis.', 'discount': 0};
    }

    int discount = v.isPercentage ? (subtotal * v.discountAmount / 100).round() : v.discountAmount;
    if (discount > subtotal) discount = subtotal;
    return {'valid': true, 'message': 'Voucher berhasil digunakan!', 'discount': discount, 'code': v.code, 'type': 'Voucher'};
  }

  Map<String, dynamic> validatePromo(String code, int subtotal) {
    final normalizedCode = code.toUpperCase().trim();
    final index = _promos.indexWhere((p) => p.code == normalizedCode);
    if (index == -1) return {'valid': false, 'message': 'Kode Promo tidak ditemukan.', 'discount': 0};
    final p = _promos[index];

    // Guard: Check expiry date
    if (p.expiryDate.isBefore(DateTime.now())) {
      return {'valid': false, 'message': 'Promo "${p.code}" sudah kedaluwarsa.', 'discount': 0};
    }

    int discount = p.isPercentage ? (subtotal * p.discountAmount / 100).round() : p.discountAmount;
    if (discount > subtotal) discount = subtotal;
    return {'valid': true, 'message': 'Promo berhasil diterapkan!', 'discount': discount, 'code': p.code, 'type': 'Promo'};
  }

  // --- BUSINESS WORKFLOW (PROD & FALLBACK) ---
  Future<({String? error, String? orderId})> placeOrder({
    required Address address,
    required String deliveryMethod,
    required int deliveryFee,
    String? voucherCode,
    required int discountAmount,
    required int ppnAmount,
    required int finalTotal,
  }) async {
    return await checkoutActiveCart(
      ppnAmount: ppnAmount,
      discountAmount: discountAmount,
      address: address,
      deliveryMethod: deliveryMethod,
      deliveryFee: deliveryFee,
      finalTotal: finalTotal,
      voucherCode: voucherCode,
    );
  }

  // --- SELLER STORE CONTROLS ---
  void createStore(Store store) { dummyStores.add(store); notifyListeners(); }
  void updateStore(Store updatedStore) {
    final index = dummyStores.indexWhere((s) => s.id == updatedStore.id);
    if (index != -1) { dummyStores[index] = updatedStore; notifyListeners(); }
  }

  /// Seller processes an incoming order (Sedang Dikemas -> Menunggu Pengirim)
  Future<void> processOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = 'Menunggu Pengirim';
      _orders[index].statusTimeline.add(OrderMilestone(
          status: 'Menunggu Pengirim',
          timestamp: DateTime.now(),
          description: 'Pesanan siap diambil kurir.'));

      try {
        // 1. Update order status in DB
        await _txRepository.updateOrderStatus(orderId, 'Menunggu Pengirim');
        // 2. Create unassigned delivery row so drivers can discover this job
        await _txRepository.upsertDelivery(orderId, null, 0);
      } catch (e) {
        debugPrint('Error syncing seller process order to DB: $e');
      }
      notifyListeners();
    }
  }

  // --- DRIVER CONTROLS ---
  void toggleDriverOnline() { _isDriverOnline = !_isDriverOnline; notifyListeners(); }

  int calculateDriverEarning(Order order) {
    double pct = order.deliveryMethod.toLowerCase() == 'instant' ? 0.8 : (order.deliveryMethod.toLowerCase() == 'next day' ? 0.7 : 0.6);
    return (order.deliveryFee * pct).round();
  }

  /// Driver picks up/takes a delivery job
  Future<bool> takeJob(String orderId, String driverId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].assignedDriverId == null) {
      _orders[index].assignedDriverId = driverId;
      _orders[index].status = 'Sedang Dikirim';
      _orders[index].statusTimeline.add(OrderMilestone(
          status: 'Sedang Dikirim',
          timestamp: DateTime.now(),
          description: 'Pesanan diambil oleh kurir.'
      ));

      // Sinkronisasi status pesanan dan log penugasan kurir ke Supabase (GAP FIXED)
      try {
        await _txRepository.updateOrderStatus(orderId, 'Sedang Dikirim');
        int potentialEarnings = calculateDriverEarning(_orders[index]);
        await _txRepository.upsertDelivery(orderId, driverId, potentialEarnings);
      } catch (e) {
        debugPrint('Error syncing driver job assignment to DB: $e');
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  /// Driver completes the delivery transaction job
  Future<void> completeJob(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = 'Pesanan Selesai';
      _orders[index].statusTimeline.add(OrderMilestone(
          status: 'Pesanan Selesai',
          timestamp: DateTime.now(),
          description: 'Pesanan selesai diserahkan ke penerima.'
      ));

      // Sinkronisasi status akhir dan pencatatan pendapatan driver ke database (GAP FIXED)
      try {
        await _txRepository.updateOrderStatus(orderId, 'Pesanan Selesai');
        int finalEarnings = calculateDriverEarning(_orders[index]);
        await _txRepository.upsertDelivery(orderId, _orders[index].assignedDriverId, finalEarnings);
      } catch (e) {
        debugPrint('Error syncing delivery completion to DB: $e');
      }
      notifyListeners();
    }
  }

  // --- ADMIN CONTROLS & SIMULATION ---
  Future<void> advanceOrderStatus(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final current = _orders[index].status;
      String next = current == 'Sedang Dikemas' ? 'Menunggu Pengirim' : (current == 'Menunggu Pengirim' ? 'Sedang Dikirim' : 'Pesanan Selesai');
      _orders[index].status = next;
      _orders[index].statusTimeline.add(OrderMilestone(
          status: next,
          timestamp: DateTime.now(),
          description: 'Status diperbarui oleh admin menjadi $next'
      ));

      try {
        await _txRepository.updateOrderStatus(orderId, next);
        if (next == 'Sedang Dikirim' || next == 'Pesanan Selesai') {
          int earnings = calculateDriverEarning(_orders[index]);
          await _txRepository.upsertDelivery(orderId, _orders[index].assignedDriverId, earnings);
        }
      } catch (e) {
        debugPrint('Error admin advancing order status: $e');
      }
      notifyListeners();
    }
  }

  Future<void> simulateNextDay() async {
    _simulatedDateTime = _simulatedDateTime.add(const Duration(days: 1));

    for (var i = 0; i < _orders.length; i++) {
      final order = _orders[i];

      // Only process non-terminal orders
      if (order.status != 'Pesanan Selesai' && order.status != 'Dikembalikan') {
        // SLA in hours — must match admin_overdue_page.dart exactly
        int slaHours = 48; // Default: Regular
        final method = order.deliveryMethod.toLowerCase();
        if (method == 'instant') slaHours = 3;
        else if (method == 'next day') slaHours = 24;

        final durationElapsed = _simulatedDateTime.difference(order.createdAt);

        // Trigger refund if SLA exceeded (hours-based, consistent with admin UI)
        if (durationElapsed.inHours >= slaHours) {
          order.status = 'Dikembalikan';
          order.statusTimeline.add(OrderMilestone(
            status: 'Dikembalikan',
            timestamp: _simulatedDateTime,
            description: 'Pesanan otomatis dikembalikan karena melewati batas waktu SLA ($method ${slaHours}j). Dana dikembalikan ke dompet pembeli.',
          ));

          // 1. Kirim status perubahan terbaru ke Supabase
          try {
            await _txRepository.updateOrderStatus(order.id, 'Dikembalikan');
            await _txRepository.upsertDelivery(order.id, order.assignedDriverId, 0); // Reversal income driver ke 0
          } catch (e) {
            debugPrint('Error updating overdue order inside core pipeline: $e');
          }

          // 2. Kirim refund dana ke SEA-Wallet Pembeli jika UUID valid
          if (_currentUser != null && order.buyerId == _currentUser!.id) {
            _walletBalance += order.finalTotal;
            try {
              await _txRepository.updateWalletBalance(order.buyerId, _walletBalance, {
                'amount': order.finalTotal,
                'type': 'refund',
              });
            } catch (e) {
              debugPrint('Error processing buyer wallet overdue automated refund: $e');
            }
          } else if (_txRepository.isValidUuid(order.buyerId)) {
            try {
              int currentBal = await _txRepository.getWalletBalance(order.buyerId);
              await _txRepository.updateWalletBalance(order.buyerId, currentBal + order.finalTotal, {
                'amount': order.finalTotal,
                'type': 'refund',
              });
            } catch (e) {
              debugPrint('Error processing side user refund payload: $e');
            }
          }

          // 3. Restorasi jumlah stok barang jualan toko di database
          for (final item in order.items) {
            final pIdx = dummyProducts.indexWhere((p) => p.id == item.productId || p.name == item.productName);
            if (pIdx != -1) {
              dummyProducts[pIdx].stock += item.quantity;
              try {
                await _txRepository.updateProductStock(dummyProducts[pIdx].id, dummyProducts[pIdx].stock);
              } catch (e) {
                debugPrint('Error syncing restored inventory values back to cloud storage: $e');
              }
            }
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> processRefund(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      // Idempotency guard: prevent double-refund on already-refunded orders
      if (_orders[index].status == 'Dikembalikan') return;

      _orders[index].status = 'Dikembalikan';
      _orders[index].statusTimeline.add(OrderMilestone(
          status: 'Dikembalikan',
          timestamp: _simulatedDateTime,
          description: 'Pesanan dibatalkan & dana direfund.'));

      try {
        await _txRepository.updateOrderStatus(orderId, 'Dikembalikan');
      } catch (e) {
        debugPrint('Error admin processing refund code sync: $e');
      }
      notifyListeners();
    }
  }

  // --- APP REVIEW ---
  void addAppReview(String name, double rating, String comment) {
    final reviewerName = name.isEmpty ? 'Anonim' : name;
    // Optimistic local insert for immediate UI feedback
    final localReview = AppReview(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      name: reviewerName,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );
    _appReviews.insert(0, localReview);
    notifyListeners();

    // Persist to Supabase asynchronously and replace local entry with DB entry on success
    _reviewRepository
        .insertReview(reviewerName: reviewerName, rating: rating, comment: comment)
        .then((dbReview) {
      if (dbReview != null) {
        final idx = _appReviews.indexWhere((r) => r.id == localReview.id);
        if (idx != -1) {
          _appReviews[idx] = dbReview;
          notifyListeners();
        }
      }
    });
  }
}
