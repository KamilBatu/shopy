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

  Future<void> addOrder(
    double totalAmount,
    DateTime orderedAt,
    List<CartItem> ordersCartItems,
  ) async {
    String baseUrl =
        'https://shoproject-e4a02-default-rtdb.firebaseio.com/orders.json';
    final Uri url = Uri.parse(baseUrl);
    try {
      final response = await http.post(url,
          body: json.encode({
            'totalAmount': totalAmount,
            'orderedAt': orderedAt.toIso8601String(),
            'ordersCartItems': ordersCartItems.map(
              (value) {
                return {
                  'id': value.id,
                  'title': value.title,
                  'price': value.price,
                  'imageUrl': value.imageUrl,
                  'quantity': value.quantity,
                };
              },
            ).toList(),
          }));
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
      }
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> fetchAndSet() async {
    String baseUrl =
        'https://shoproject-e4a02-default-rtdb.firebaseio.com/orders.json';
    final Uri url = Uri.parse(baseUrl);

    final List<Order> _loadedList = [];
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    // ignore: unnecessary_null_comparison
    if (extractedData == null) {
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
  }
}
