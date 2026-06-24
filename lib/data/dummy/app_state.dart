import 'package:flutter/material.dart';
import '../models/models.dart';
import 'dummy_data.dart';

class AppState extends ChangeNotifier {
  // --- AUTH STATE ---
  User? _currentUser;
  bool _isLoggedIn = false;
  String _activeRole = 'Guest'; // 'Guest', 'Buyer', 'Seller', 'Driver'

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String get activeRole => _activeRole;
  List<String> get availableRoles => _currentUser?.roles ?? [];

  bool login(String username, String password) {
    // TODO: replace with real API call
    final normalized = username.toLowerCase().trim();
    try {
      final user = dummyUsers.firstWhere(
        (u) => u.email.toLowerCase() == normalized || u.username.toLowerCase() == normalized,
      );
      if (user.password == password) {
        _currentUser = user;
        _isLoggedIn = true;
        _activeRole = user.roles.first;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  void logout() {
    // TODO: replace with real API call
    _isLoggedIn = false;
    _currentUser = null;
    _activeRole = 'Guest';
    _cartItems.clear(); // Clear cart on logout
    notifyListeners();
  }

  void setActiveRole(String role) {
    if (_isLoggedIn && _currentUser != null && _currentUser!.roles.contains(role)) {
      _activeRole = role;
      notifyListeners();
    }
  }

  // --- STORE HELPER (Seller) ---
  Store? get currentUserStore {
    if (_currentUser == null) return null;
    try {
      return dummyStores.firstWhere((store) => store.ownerId == _currentUser!.id);
    } catch (_) {
      return null;
    }
  }

  // --- STORE MANAGEMENT (Seller) ---
  void createStore(Store store) {
    // TODO: replace with real API call
    dummyStores.add(store);
    notifyListeners();
  }

  void updateStore(Store updatedStore) {
    // TODO: replace with real API call
    final index = dummyStores.indexWhere((s) => s.id == updatedStore.id);
    if (index != -1) {
      dummyStores[index] = updatedStore;
      notifyListeners();
    }
  }

  // --- PRODUCT MANAGEMENT CRUD (Seller) ---
  void addProduct(Product product) {
    // TODO: replace with real API call
    dummyProducts.add(product);
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    // TODO: replace with real API call
    final index = dummyProducts.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      dummyProducts[index] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    // TODO: replace with real API call
    dummyProducts.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  // --- ORDER PROCESSING (Seller) ---
  void processOrder(String orderId) {
    // TODO: replace with real API call
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      if (order.status == 'Sedang Dikemas') {
        order.status = 'Menunggu Pengirim';
        order.statusTimeline.add(OrderMilestone(
          status: 'Menunggu Pengirim',
          timestamp: DateTime.now(),
          description: 'Pesanan siap diambil kurir. Penjual telah memproses pesanan.',
        ));
        notifyListeners();
      }
    }
  }

  // --- WALLET STATE ---
  int _walletBalance = 10000000; // Start with Rp 10.000.000
  final List<WalletTransaction> _walletTransactions = [
    WalletTransaction(
      id: 'tx_init',
      type: 'topup',
      amount: 10000000,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      title: 'Saldo Awal Sistem',
    ),
  ];

  int get walletBalance => _walletBalance;
  List<WalletTransaction> get walletTransactions => _walletTransactions;

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
  }

  bool deductWallet(int amount, String orderId) {
    if (_walletBalance < amount) return false;
    _walletBalance -= amount;
    _walletTransactions.insert(
      0,
      WalletTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: 'payment',
        amount: amount,
        timestamp: DateTime.now(),
        title: 'Pembayaran Order $orderId',
      ),
    );
    notifyListeners();
    return true;
  }

  // --- ADDRESS STATE ---
  final List<Address> _addresses = List.from(dummyAddresses);

  List<Address> get addresses => _addresses;
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

  void addAddress(Address address) {
    if (address.isDefault) {
      // Set all other addresses isDefault = false
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

  // --- CART STATE ---
  final List<CartItem> _cartItems = [];
  String? _cartStoreId;

  List<CartItem> get cartItems => _cartItems;
  String? get cartStoreId => _cartStoreId;

  Store? get cartStore {
    if (_cartStoreId == null) return null;
    return dummyStores.firstWhere((s) => s.id == _cartStoreId);
  }

  int get cartSubtotal {
    return _cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Add item, returns true if success, false if store conflict
  bool addToCart(Product product, {bool forceClear = false}) {
    if (forceClear) {
      _cartItems.clear();
      _cartStoreId = product.storeId;
    }

    if (_cartItems.isEmpty) {
      _cartStoreId = product.storeId;
    } else if (_cartStoreId != product.storeId) {
      // Store conflict!
      return false;
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
      if (_cartItems.isEmpty) {
        _cartStoreId = null;
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    if (_cartItems.isEmpty) {
      _cartStoreId = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _cartStoreId = null;
    notifyListeners();
  }

  // --- VOUCHER & PROMO VALIDATION ---
  final List<Voucher> _vouchers = List.from(dummyVouchers);
  final List<Promo> _promos = List.from(dummyPromos);

  List<Voucher> get vouchers => _vouchers;
  List<Promo> get promos => _promos;

  // Validate Voucher. Returns Map with status, message, and discount calculation
  Map<String, dynamic> validateVoucher(String code, int subtotal) {
    final normalizedCode = code.toUpperCase().trim();
    final index = _vouchers.indexWhere((v) => v.code == normalizedCode);
    if (index == -1) {
      return {'valid': false, 'message': 'Kode Voucher tidak ditemukan', 'discount': 0};
    }
    final v = _vouchers[index];
    if (v.expiryDate.isBefore(DateTime.now())) {
      return {'valid': false, 'message': 'Voucher sudah kedaluwarsa', 'discount': 0};
    }
    if (v.quotaRemaining <= 0) {
      return {'valid': false, 'message': 'Kuota Voucher telah habis', 'discount': 0};
    }

    int discount = 0;
    if (v.isPercentage) {
      discount = (subtotal * v.discountAmount / 100).round();
    } else {
      discount = v.discountAmount;
    }
    // Limit discount to subtotal
    if (discount > subtotal) discount = subtotal;

    return {
      'valid': true,
      'message': 'Voucher berhasil digunakan! Diskon Rp${discount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
      'discount': discount,
      'code': v.code,
      'type': 'Voucher'
    };
  }

  // Validate Promo. Returns Map
  Map<String, dynamic> validatePromo(String code, int subtotal) {
    final normalizedCode = code.toUpperCase().trim();
    final index = _promos.indexWhere((p) => p.code == normalizedCode);
    if (index == -1) {
      return {'valid': false, 'message': 'Kode Promo tidak ditemukan', 'discount': 0};
    }
    final p = _promos[index];
    if (p.expiryDate.isBefore(DateTime.now())) {
      return {'valid': false, 'message': 'Promo sudah kedaluwarsa', 'discount': 0};
    }

    int discount = 0;
    if (p.isPercentage) {
      discount = (subtotal * p.discountAmount / 100).round();
    } else {
      discount = p.discountAmount;
    }
    if (discount > subtotal) discount = subtotal;

    return {
      'valid': true,
      'message': 'Promo berhasil diterapkan! Potongan Rp${discount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
      'discount': discount,
      'code': p.code,
      'type': 'Promo'
    };
  }

  // Deduct Voucher Quota on checkout
  void useVoucherQuota(String code) {
    final index = _vouchers.indexWhere((v) => v.code == code);
    if (index != -1 && _vouchers[index].quotaRemaining > 0) {
      _vouchers[index].quotaRemaining -= 1;
      notifyListeners();
    }
  }

  // --- ORDERS STATE ---
  // --- DRIVER STATE ---
  bool _isDriverOnline = true;
  bool get isDriverOnline => _isDriverOnline;

  void toggleDriverOnline() {
    _isDriverOnline = !_isDriverOnline;
    notifyListeners();
  }

  double getDriverEarningPercentage(String method) {
    // Instant: 80%, Next Day: 70%, Regular/others: 60%
    switch (method.toLowerCase()) {
      case 'instant':
        return 0.8;
      case 'next day':
        return 0.7;
      case 'regular':
      default:
        return 0.6;
    }
  }

  int calculateDriverEarning(Order order) {
    final pct = getDriverEarningPercentage(order.deliveryMethod);
    return (order.deliveryFee * pct).round();
  }

  // Take a job (Find Available Jobs -> Active Job)
  bool takeJob(String orderId, String driverId) {
    // Business Rule: A driver can only have 1 active job at a time
    final hasActiveJob = _orders.any((o) => o.assignedDriverId == driverId && o.status == 'Sedang Dikirim');
    if (hasActiveJob) {
      return false;
    }

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      // Defensive check: order must be 'Menunggu Pengirim' and have no driver assigned
      if (order.status == 'Menunggu Pengirim' && order.assignedDriverId == null) {
        order.assignedDriverId = driverId;
        order.status = 'Sedang Dikirim';
        order.statusTimeline.add(OrderMilestone(
          status: 'Sedang Dikirim',
          timestamp: DateTime.now(),
          description: 'Pesanan telah diambil oleh kurir dan sedang dalam perjalanan ke alamat Anda.',
        ));
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Complete a job (Active Job -> History)
  void completeJob(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      if (order.status == 'Sedang Dikirim') {
        order.status = 'Pesanan Selesai';
        order.statusTimeline.add(OrderMilestone(
          status: 'Pesanan Selesai',
          timestamp: DateTime.now(),
          description: 'Pesanan selesai diserahkan ke penerima oleh kurir.',
        ));
        notifyListeners();
      }
    }
  }

  // --- ORDERS STATE ---
  final List<Order> _orders = List.from(dummyOrders);

  List<Order> get orders => _orders;

  void placeOrder({
    required Address address,
    required String deliveryMethod,
    required int deliveryFee,
    String? voucherCode,
    required int discountAmount,
    required int ppnAmount,
    required int finalTotal,
  }) {
    if (_cartItems.isEmpty || _cartStoreId == null) return;
    final store = cartStore!;

    final orderId = 'ORD-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Deduct stock for each product in dummy list
    for (var item in _cartItems) {
      final pIndex = dummyProducts.indexWhere((p) => p.id == item.product.id);
      if (pIndex != -1) {
        dummyProducts[pIndex].stock = (dummyProducts[pIndex].stock - item.quantity).clamp(0, 9999);
      }
    }

    final newOrderItems = _cartItems.map((item) => OrderItem(
      productName: item.product.name,
      price: item.product.price,
      quantity: item.quantity,
      imageUrl: item.product.imageUrl,
    )).toList();

    final newOrder = Order(
      id: orderId,
      storeName: store.name,
      storeId: store.id,
      items: newOrderItems,
      address: address,
      deliveryMethod: deliveryMethod,
      deliveryFee: deliveryFee,
      voucherCode: voucherCode,
      discountAmount: discountAmount,
      ppnAmount: ppnAmount,
      finalTotal: finalTotal,
      status: 'Sedang Dikemas',
      statusTimeline: [
        OrderMilestone(
          status: 'Sedang Dikemas',
          timestamp: DateTime.now(),
          description: 'Pesanan telah berhasil dibayar. Seller sedang memproses kemasan.',
        ),
      ],
      assignedDriverId: null,
      pickupAddress: '${store.name} - ${store.location}',
      dropoffAddress: address.fullAddress,
    );

    // Deduct Wallet
    deductWallet(finalTotal, orderId);

    // Decrease Voucher Quota if applicable
    if (voucherCode != null) {
      useVoucherQuota(voucherCode);
    }

    _orders.insert(0, newOrder);
    clearCart(); // clear cart after checkout
    notifyListeners();
  }

  // Update order status to help verify flow manual
  void advanceOrderStatus(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final o = _orders[index];
      String nextStatus;
      String desc;

      if (o.status == 'Sedang Dikemas') {
        nextStatus = 'Menunggu Pengirim';
        desc = 'Pesanan siap diambil kurir.';
      } else if (o.status == 'Menunggu Pengirim') {
        nextStatus = 'Sedang Dikirim';
        desc = 'Pesanan dalam perjalanan kurir ke tujuan.';
      } else if (o.status == 'Sedang Dikirim') {
        nextStatus = 'Pesanan Selesai';
        desc = 'Pesanan telah sampai dan diterima dengan baik.';
      } else if (o.status == 'Pesanan Selesai') {
        nextStatus = 'Dikembalikan';
        desc = 'Pesanan diajukan komplain dan dikembalikan (refund).';
      } else {
        nextStatus = 'Sedang Dikemas';
        desc = 'Pesanan di-reset untuk demo.';
      }

      o.status = nextStatus;
      o.statusTimeline.add(OrderMilestone(
        status: nextStatus,
        timestamp: DateTime.now(),
        description: desc,
      ));
      notifyListeners();
    }
  }

  // --- REVIEW APLIKASI STATE ---
  final List<AppReview> _appReviews = List.from(dummyAppReviews);

  List<AppReview> get appReviews => _appReviews;

  void addAppReview(String name, double rating, String comment) {
    final newReview = AppReview(
      id: 'app_rev_${DateTime.now().millisecondsSinceEpoch}',
      name: name.isEmpty ? 'Anonim' : name,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );
    _appReviews.insert(0, newReview);
    notifyListeners();
  }
}
