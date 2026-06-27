import 'package:equatable/equatable.dart';
import '../../../../data/models/models.dart';

abstract class SellerState extends Equatable {
  const SellerState();

  @override
  List<Object?> get props => [];
}

class SellerInitial extends SellerState {}

// --- STORE STATES ---
class StoreLoading extends SellerState {}

class StoreLoaded extends SellerState {
  final Store? store;

  const StoreLoaded(this.store);

  @override
  List<Object?> get props => [store];
}

class StoreSavedState extends SellerState {
  final Store store;

  const StoreSavedState(this.store);

  @override
  List<Object?> get props => [store];
}

class StoreError extends SellerState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- PRODUCT STATES ---
class ProductsLoading extends SellerState {}

class ProductsLoaded extends SellerState {
  final List<Product> products;

  const ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductCrudSuccess extends SellerState {
  final String message;

  const ProductCrudSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductsError extends SellerState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
