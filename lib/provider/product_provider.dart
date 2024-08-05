import 'package:flutter/material.dart';
import './product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  static const String baseUrl =
      'https://shoproject-e4a02-default-rtdb.firebaseio.com/products.json';
  final Uri url = Uri.parse(baseUrl);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Future<void> fetchAndSet() async {
    try {
      final response = await http.get(url);
      final Map<String, dynamic> res = json.decode(response.body);
      List<Product> _tempProductList = [];
      res.forEach(
        (key, value) {
          _tempProductList.add(
            Product(
                id: key,
                description: value['description'],
                imageUrl: value['imageUrl'],
                price: value['price'],
                title: value['title'],
                isFavorite: value['isFavorite']),
          );
        },
      );
      _items = _tempProductList;
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to fetch products: $error');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          },
        ),
      );
      final String productId = json.decode(response.body)['name'];
      final productAdd = Product(
        id: productId,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
        isFavorite: product.isFavorite,
      );
      _items.insert(0, productAdd);
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to add product: $error');
    }
  }

  Product findById(String productId) {
    return _items.firstWhere((p) => p.id == productId);
  }

  Future<void> updateProduct(Product product, String id) async {
    final int productIndex = _items.indexWhere((prod) => prod.id == id);
    final Uri productUrl = Uri.parse(
        'https://shoproject-e4a02-default-rtdb.firebaseio.com/products/$id.json');

    if (productIndex >= 0) {
      try {
        await http.patch(
          productUrl,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }),
        );
        _items[productIndex] = product;
        notifyListeners();
      } catch (error) {
        throw Exception('Failed to update product: $error');
      }
    } else {
      print('Product not found');
    }
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((prod) => prod.id == id);

    // Make a local change and notify listeners
    final removedProduct = _items.removeAt(index);
    notifyListeners();

    final Uri productUrl = Uri.parse(
        'https://shoproject-e4a02-default-rtdb.firebaseio.com/products/$id.json');

    try {
      final response = await http.delete(productUrl);

      if (response.statusCode >= 400) {
        // Rollback the local change if the deletion fails
        _items.insert(index, removedProduct);
        notifyListeners();
        throw HttpException('Couldn\'t delete the product');
      }
    } catch (error) {
      // Rollback and handle other potential errors
      notifyListeners();
      print('Error during HTTP delete request: $error');
      throw HttpException('Failed to delete product: $error');
    }
  }
}
