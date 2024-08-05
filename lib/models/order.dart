import '../models/cart.dart';

class Order {
  final String id;
  final double totalAmount;
  final DateTime orderedAt;
  final List<CartItem> ordersCartItems;
  Order({
    required this.id,
    required this.totalAmount,
    required this.orderedAt,
    required this.ordersCartItems,
  });
}
