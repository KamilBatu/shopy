// import 'dart:convert';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String description;
  final String title;
  final double price;
  final String imageUrl;
  bool isFavorite;
  Product({
    required this.id,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.title,
    this.isFavorite = false,
  });
  Future<void> toggleFavorite(AuthToken, userId) async {
    final oldFavorite = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final Uri productUrl = Uri.parse(
        'https://shoproject-e4a02-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$AuthToken');
    try {
      final response =
          await http.put(productUrl, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        isFavorite = oldFavorite;
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }
}
