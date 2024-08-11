import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopy/models/cart.dart';
import '../models/order.dart';
import 'package:http/http.dart' as http;

class OrdersProvider with ChangeNotifier {
  List<Order> _ordersList = [];
  List<Order> get ordersList {
    return [..._ordersList];
  }

  String? authToken;
  String? userId;
  OrdersProvider(this.authToken, this.userId, this._ordersList);

  Future<void> addOrder(
    double totalAmount,
    DateTime orderedAt,
    List<CartItem> ordersCartItems,
  ) async {
    final String baseUrl =
        'https://shoproject-e4a02-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final Uri url = Uri.parse(baseUrl);
    try {
      final response = await http.post(url,
          body: json.encode({
            'totalAmount': totalAmount,
            'orderedAt': orderedAt.toIso8601String(),
            'ordersCartItems': ordersCartItems.map((value) {
              return {
                'id': value.id,
                'title': value.title,
                'price': value.price,
                'imageUrl': value.imageUrl,
                'quantity': value.quantity,
              };
            }).toList(),
          }));
      if (response.statusCode >= 400) {
        throw Exception('Failed to add order');
      }
      if (totalAmount > 0) {
        _ordersList.insert(
          0,
          Order(
            id: json.decode(response.body)['name'],
            totalAmount: totalAmount,
            orderedAt: orderedAt,
            ordersCartItems: ordersCartItems,
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      throw e; // Consider more specific error handling.
    }
  }

  Future<void> fetchAndSet() async {
    final List<Order> _loadedList = [];
    final String baseUrl =
        'https://shoproject-e4a02-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final Uri url = Uri.parse(baseUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        throw Exception('Failed to fetch orders');
      }
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null || extractedData.isEmpty) {
        return;
      }
      extractedData.forEach((orderID, orderData) {
        _loadedList.add(Order(
          id: orderID,
          totalAmount: orderData['totalAmount'],
          orderedAt: DateTime.parse(orderData['orderedAt']),
          ordersCartItems: (orderData['ordersCartItems'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    price: item['price'],
                    imageUrl: item['imageUrl'],
                    quantity: item['quantity'],
                  ))
              .toList(),
        ));
      });
      _ordersList = _loadedList;
      notifyListeners();
    } catch (e) {
      throw e; // Consider logging or handling the error more gracefully.
    }
  }
}
