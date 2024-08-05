import 'package:flutter/material.dart';
import '../models/cart.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};
  Map<String, CartItem> get cartItem {
    return {..._cartItems};
  }

  void addItem(
    String prodId,
    String title,
    double price,
    String imageUrl,
  ) {
    if (_cartItems.containsKey(prodId)) {
      _cartItems.update(
        prodId,
        (value) {
          return CartItem(
            id: value.id,
            title: value.title,
            price: value.price,
            imageUrl: value.imageUrl,
            quantity: value.quantity + 1,
          );
        },
      );
    } else {
      _cartItems.putIfAbsent(
        prodId,
        () {
          return CartItem(
              id: DateTime.now().toString(),
              title: title,
              price: price,
              imageUrl: imageUrl,
              quantity: 1);
        },
      );
    }
    notifyListeners();
  }

  void addAdd(prodId) {}

  void clearCart() {
    _cartItems = {};
    notifyListeners();
  }

  int items() {
    return _cartItems.length;
  }

  double totalPrice() {
    double _totalPrice = 0; // Initialize the total price within the function
    _cartItems.forEach((key, value) {
      _totalPrice += value.price * value.quantity; // Accumulate the price
    });
    return _totalPrice;
  }

  void removeItem(String prodId) {
    _cartItems.remove(prodId);
    notifyListeners();
  }

  void undoItem(prodId) {
    if (_cartItems[prodId]!.quantity > 1) {
      _cartItems.update(prodId, (value) {
        return CartItem(
            id: value.id,
            title: value.title,
            price: value.price,
            imageUrl: value.imageUrl,
            quantity: value.quantity - 1);
      });
    } else {
      _cartItems.remove(prodId);
    }
    notifyListeners();
  }

  void plus(String id) {
    _cartItems.update(
      id,
      (value) {
        if (value.quantity < 12) {
          return CartItem(
            id: value.id,
            title: value.title,
            price: value.price,
            imageUrl: value.imageUrl,
            quantity: value.quantity + 1,
          );
        } else {
          return CartItem(
              id: value.id,
              title: value.title,
              price: value.price,
              imageUrl: value.imageUrl,
              quantity: value.quantity);
        }
      },
    );
    notifyListeners();
  }

  void minus(String id) {
    _cartItems.update(
      id,
      (value) {
        if (value.quantity > 0) {
          return CartItem(
            id: value.id,
            title: value.title,
            price: value.price,
            imageUrl: value.imageUrl,
            quantity: value.quantity - 1,
          );
        } else {
          return CartItem(
              id: value.id,
              title: value.title,
              price: value.price,
              imageUrl: value.imageUrl,
              quantity: value.quantity);
        }
      },
    );
    notifyListeners();
  }
}
