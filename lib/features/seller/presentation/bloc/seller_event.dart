import 'package:equatable/equatable.dart';

abstract class SellerEvent extends Equatable {
  const SellerEvent();

  @override
  List<Object?> get props => [];
}

class LoadStore extends SellerEvent {
  final String sellerId;

  const LoadStore(this.sellerId);

  @override
  List<Object?> get props => [sellerId];
}

class SaveStore extends SellerEvent {
  final String sellerId;
  final String? storeId; // Null if creating a new store, non-null if editing
  final String name;
  final String location;
  final String description;
  final String logoUrl;

  const SaveStore({
    required this.sellerId,
    this.storeId,
    required this.name,
    required this.location,
    required this.description,
    this.logoUrl = 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=100&auto=format&fit=crop',
  });

  @override
  List<Object?> get props => [sellerId, storeId, name, location, description, logoUrl];
}

class LoadSellerProducts extends SellerEvent {
  final String storeId;

  const LoadSellerProducts(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

class CreateProductEvent extends SellerEvent {
  final String storeId;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String category;
  final String imageUrl;

  const CreateProductEvent({
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [storeId, name, description, price, stock, category, imageUrl];
}

class UpdateProductEvent extends SellerEvent {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String category;
  final String imageUrl;

  const UpdateProductEvent({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, storeId, name, description, price, stock, category, imageUrl];
}

class DeleteProductEvent extends SellerEvent {
  final String productId;
  final String storeId;

  const DeleteProductEvent({
    required this.productId,
    required this.storeId,
  });

  @override
  List<Object?> get props => [productId, storeId];
}
