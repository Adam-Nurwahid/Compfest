class User {
  final String id;
  final String name;
  final String email;
  final String username;
  final String password;
  final List<String> roles; // e.g. ['Buyer', 'Seller']
  String activeRole; // Currently active role in the session

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.roles,
    required this.activeRole,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    String? password,
    List<String>? roles,
    String? activeRole,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      roles: roles ?? this.roles,
      activeRole: activeRole ?? this.activeRole,
    );
  }
}

class Store {
  final String id;
  final String sellerId;
  final String name;
  final String location;
  final String logoUrl;
  final double rating;
  final String description;

  Store({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.location,
    required this.logoUrl,
    required this.rating,
    required this.description,
  });
}

class Product {
  final String id;
  final String storeId;
  final String name;
  final int price; // in Rupiah (IDR)
  int stock;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
  });
}

class AppReview {
  final String id;
  final String name;
  final double rating;
  final String comment;
  final DateTime date;

  AppReview({
    required this.id,
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class WalletTransaction {
  final String id;
  final String type; // 'topup' or 'payment' or 'refund'
  final int amount;
  final DateTime timestamp;
  final String title;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.title,
  });
}

class Address {
  final String id;
  final String receiverName;
  final String phoneNumber;
  final String fullAddress;
  final bool isDefault;

  Address({
    required this.id,
    required this.receiverName,
    required this.phoneNumber,
    required this.fullAddress,
    required this.isDefault,
  });

  Address copyWith({
    String? id,
    String? receiverName,
    String? phoneNumber,
    String? fullAddress,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      receiverName: receiverName ?? this.receiverName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullAddress: fullAddress ?? this.fullAddress,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });
}

class Voucher {
  final String code;
  final int discountAmount; // could be absolute or percentage
  final bool isPercentage;
  final DateTime expiryDate;
  int quotaRemaining;

  Voucher({
    required this.code,
    required this.discountAmount,
    required this.isPercentage,
    required this.expiryDate,
    required this.quotaRemaining,
  });
}

class Promo {
  final String code;
  final int discountAmount;
  final bool isPercentage;
  final DateTime expiryDate;

  Promo({
    required this.code,
    required this.discountAmount,
    required this.isPercentage,
    required this.expiryDate,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final int price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id']?.toString() ?? '',
      productName: json['products'] != null ? (json['products']['name'] ?? 'Produk') : 'Produk',
      price: (json['price_at_purchase'] as num?)?.toInt() ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      imageUrl: 'https://images.unsplash.com/photo-1530541930197-ff16ac917b0e?w=500&auto=format&fit=crop',
    );
  }
}

class OrderMilestone {
  final String status;
  final DateTime timestamp;
  final String description;

  OrderMilestone({
    required this.status,
    required this.timestamp,
    required this.description,
  });

  factory OrderMilestone.fromJson(Map<String, dynamic> json) {
    return OrderMilestone(
      status: json['status'] ?? 'Sedang Dikemas',
      timestamp: json['changed_at'] != null
          ? DateTime.parse(json['changed_at'])
          : DateTime.now(),
      description: 'Status berubah menjadi ${json['status']}',
    );
  }
}

class Order {
  final String id;
  final String buyerId;
  final DateTime createdAt;
  final String storeName;
  final String storeId;
  final List<OrderItem> items;
  final Address address;
  final String deliveryMethod;
  final int deliveryFee;
  final String? voucherCode;
  final int discountAmount;
  final int ppnAmount;
  final int finalTotal;
  String status;
  final List<OrderMilestone> statusTimeline;
  String? assignedDriverId;
  final String pickupAddress;
  final String dropoffAddress;

  Order({
    required this.id,
    required this.buyerId,
    required this.createdAt,
    required this.storeName,
    required this.storeId,
    required this.items,
    required this.address,
    required this.deliveryMethod,
    required this.deliveryFee,
    this.voucherCode,
    required this.discountAmount,
    required this.ppnAmount,
    required this.finalTotal,
    required this.status,
    required this.statusTimeline,
    this.assignedDriverId,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItem>[];
    if (json['order_items'] != null) {
      itemsList = (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    var timeline = <OrderMilestone>[];
    if (json['order_status_history'] != null) {
      timeline = (json['order_status_history'] as List)
          .map((h) => OrderMilestone.fromJson(h))
          .toList();
    } else {
      timeline = [
        OrderMilestone(
          status: json['status'] ?? 'Sedang Dikemas',
          timestamp: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
          description: 'Pesanan berhasil dibuat dengan status: ${json['status'] ?? 'Sedang Dikemas'}',
        )
      ];
    }

    return Order(
      id: json['id']?.toString() ?? '',
      buyerId: json['buyer_id']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      storeName: json['stores'] != null ? (json['stores']['name'] ?? 'Toko Seapedia') : 'Toko Seapedia',
      storeId: json['store_id']?.toString() ?? '',
      items: itemsList,
      address: Address(
        id: 'addr_order',
        receiverName: 'Penerima',
        phoneNumber: '',
        fullAddress: json['shipping_address'] ?? '',
        isDefault: false,
      ),
      deliveryMethod: json['delivery_method']?.toString() ?? 'Regular',
      deliveryFee: (json['delivery_fee'] as num?)?.toInt() ?? 0,
      voucherCode: json['discounts'] != null ? json['discounts']['code']?.toString() : null,
      discountAmount: (json['discount_amount'] as num?)?.toInt() ?? 0,
      ppnAmount: (json['ppn_amount'] as num?)?.toInt() ?? 0,
      finalTotal: (json['final_total'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'Sedang Dikemas',
      statusTimeline: timeline,
      assignedDriverId: json['deliveries'] != null ? json['deliveries']['driver_id']?.toString() : null,
      pickupAddress: 'Gudang Penjual',
      dropoffAddress: json['shipping_address'] ?? '',
    );
  }
}