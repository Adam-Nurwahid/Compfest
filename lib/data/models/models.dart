class Store {
  final String id;
  final String name;
  final String location;
  final String logoUrl;
  final double rating;
  final String description;

  Store({
    required this.id,
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
  final String type; // 'topup' or 'payment'
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
  final String productName;
  final int price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}

class Order {
  final String id;
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
  String status; // 'Sedang Dikemas', 'Menunggu Pengirim', 'Sedang Dikirim', 'Pesanan Selesai', 'Dikembalikan'
  final List<OrderMilestone> statusTimeline;

  Order({
    required this.id,
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
  });
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
}
