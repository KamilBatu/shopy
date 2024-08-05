import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopy/provider/cart_provider.dart';
// import 'package:shopy/provider/product_provider.dart';

class CartItemWidget extends StatelessWidget {
  final String id;
  final String title;
  final String imageurl;
  final double price;
  final int quantity;
  final String prodId;
  CartItemWidget(this.id, this.title, this.imageurl, this.price, this.quantity,
      this.prodId);

  @override
  Widget build(BuildContext context) {
    final cartA = Provider.of<CartProvider>(context);
    // final productItem = Provider.of<ProductProvider>(context);

    return Container(
      child: Card(
        elevation: 4,
        child: ListTile(
          tileColor: Colors.white30,
          leading: Image.network(imageurl),
          title: Text('\$${price * quantity}'),
          subtitle: Text(title),
          textColor: Colors.blueGrey,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // Handle addition action
                  cartA.plus(prodId);
                },
                child: const Chip(
                  shape: CircleBorder(),
                  backgroundColor: Colors.deepPurple,
                  label: Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.white, // Smaller size
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  '${quantity}x',
                  style: TextStyle(fontSize: 22, color: Colors.black),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle subtraction action
                  cartA.undoItem(prodId);
                },
                child: const Chip(
                  shape: CircleBorder(),
                  backgroundColor: Colors.red,
                  label: Icon(
                    Icons.remove,
                    size: 16, // Smaller si
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          dense: false,
        ),
      ),
    );
  }
}
