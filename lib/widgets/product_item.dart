import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopy/provider/cart_provider.dart';
import '../provider/product.dart';
import '../screens/product_detail.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    print('rebuilding ...');
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              ProductDetail.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (context, p, _) => IconButton(
              icon: Icon(p.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                p.toggleFavorite();
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: Consumer<CartProvider>(
            builder: (context, value, child) => IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                value.addItem(
                  product.id,
                  product.title,
                  product.price,
                  product.imageUrl,
                );
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('added to the cart!'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          cart.undoItem(product.id);
                        }),
                  ),
                );
              },
            ),
          ),
          backgroundColor: Colors.black38,
        ),
      ),
    );
  }
}
