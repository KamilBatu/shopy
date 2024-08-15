import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopy/provider/cart_provider.dart';
// import 'package:shopy/provider/product.dart';
import 'package:shopy/provider/product_provider.dart';
// import '../assets/dummy_data.dart';

class ProductDetail extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final p = Provider.of<ProductProvider>(context);
    final c = Provider.of<CartProvider>(context);
    // final product = Provider.of<>(context);

    final productItem = p.findById(productId);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Center(
            child: Text(
          productItem.title,
          style: TextStyle(color: Colors.white),
        )),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
                tag: productItem.id,
                child: Image.network(productItem.imageUrl)),
            Card(
              child: ListTile(
                leading: Text(
                  productItem.title,
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                ),
                title: Chip(
                  label: Text(
                    '\$${productItem.price}',
                    style: TextStyle(fontSize: 18),
                  ),
                  // shape: CircleBorder(side: BorderSide.none),

                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.deepPurple),
                ),
                trailing: IconButton(
                    onPressed: () {
                      c.addItem(productItem.id, productItem.title,
                          productItem.price, productItem.imageUrl);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('added to your cart'),
                          action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                c.undoItem(productItem.id);
                              }),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.deepPurple,
                      size: 28,
                    )),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                productItem.description,
                style: TextStyle(fontSize: 18, color: Colors.black),
                textAlign: TextAlign.start,
              ),
              color: Color.fromARGB(255, 236, 234, 234),
            ),
          ],
        ),
      ),
    );
  }
}
