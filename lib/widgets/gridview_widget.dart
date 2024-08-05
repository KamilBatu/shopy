import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopy/provider/product.dart';
import 'package:shopy/provider/product_provider.dart';
import 'package:shopy/widgets/product_item.dart';

class GridviewWidget extends StatelessWidget {
  final bool filter;
  GridviewWidget(this.filter);
  @override
  Widget build(BuildContext context) {
    final p = Provider.of<ProductProvider>(context);
    final productItems = filter ? p.favoriteItems : p.items;
    return GridView.builder(
      itemCount: productItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) => ChangeNotifierProvider<Product>.value(
        value: productItems[index],
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ProductItem(),
        ),
      ),
    );
  }
}
