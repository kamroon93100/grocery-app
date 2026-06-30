import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  double get subtotal => product.finalPrice * quantity;

  Map<String, dynamic> toJson() => {
    'product':  product.toJson(),
    'quantity': quantity,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
    CartItemModel(
      product:  ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
}


