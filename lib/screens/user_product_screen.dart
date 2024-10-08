import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';
import '../widgets/drawer.dart';
import '../widgets/user_product_widget.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/loading.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-product-screen';

  Future<void> _refresh(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchAndSet(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        title: Text(
          'User Products',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: FutureBuilder(
        future: _refresh(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading('Fetching...');
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred!'));
          } else {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: Consumer<ProductProvider>(
                builder: (ctx, productData, _) => Padding(
                  padding: EdgeInsets.all(10),
                  child: ListView.builder(
                    itemCount: productData.items.length,
                    itemBuilder: (_, index) {
                      return UserProductWidget(
                        productData.items[index].id,
                        productData.items[index].title,
                        productData.items[index].imageUrl,
                      );
                    },
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
