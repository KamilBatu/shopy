import 'package:flutter/material.dart';
import './product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  static const String baseUrl = 'shoproject-e4a02-default-rtdb.firebaseio.com';

  String? authToken;
  String? userId;

  ProductProvider(this.authToken, this.userId, this._items);

  Uri getUri(String path, [Map<String, String>? queryParams]) {
    final Map<String, String> params = {'auth': authToken!};
    if (queryParams != null) {
      params.addAll(queryParams);
    }
    return Uri.https(baseUrl, path, params);
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Future<void> fetchAndSet([bool filterByuserId = false]) async {
    final filterOption = filterByuserId
        ? {
            'orderBy': '"creatorId"',
            'equalTo': '"$userId"',
          }
        : null;
    var url = getUri('/products.json', filterOption as Map<String, String>?);
    try {
      final response = await http.get(url);
      if (response.body == 'null') return;

      final Uri productUrl = Uri.parse(
          'https://shoproject-e4a02-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(productUrl);
      final favoriteData = json.decode(favoriteResponse.body);

      final Map<String, dynamic> res = json.decode(response.body);
      List<Product> _tempProductList = [];
      res.forEach(
        (prodId, value) {
          _tempProductList.add(
            Product(
              id: prodId,
              description: value['description'],
              imageUrl: value['imageUrl'],
              price: value['price'],
              title: value['title'],
              isFavorite:
                  favoriteData == null ? false : favoriteData[prodId] ?? false,
            ),
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
    final url = getUri('/products.json');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
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
    final Uri productUrl = getUri('/products/$id.json');

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

    final Uri productUrl = getUri('/products/$id.json');

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
      _items.insert(index, removedProduct);
      notifyListeners();
      print('Error during HTTP delete request: $error');
      throw HttpException('Failed to delete product: $error');
    }
  }
}
