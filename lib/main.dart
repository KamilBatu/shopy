import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopy/screens/product_overview_screen.dart';
import './provider/auth_provider.dart';
import './provider/orders_provider.dart';
import './provider/cart_provider.dart';
import './provider/product_provider.dart';
// import './screens/product_overview_screen.dart';
import './screens/product_detail.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_product_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './widgets/loading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
            create: (BuildContext context) => ProductProvider(null, null, []),
            update: (BuildContext context, AuthProvider auth,
                ProductProvider? previousProducts) {
              return ProductProvider(
                auth.token,
                auth.userId, // Passing the token from AuthProvider
                previousProducts?.items ??
                    [], // Passing previous items if available
              );
            },
          ),
          ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
            create: (BuildContext context) => OrdersProvider(null, null, []),
            update: (BuildContext context, AuthProvider auth,
                OrdersProvider? previousProducts) {
              return OrdersProvider(
                auth.token, // Passing the token from AuthProvider
                auth.userId,
                previousProducts?.ordersList ??
                    [], // Passing previous items if available
              );
            },
          ),
          ChangeNotifierProvider<CartProvider>(
            create: (_) => CartProvider(),
          ),

          // ChangeNotifierProvider<Product
          //   create: (_) => Product(),
          // ),
        ],
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(),
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? LoadingScreen('loading')
                            : AuthScreen(),
                  ),
            routes: {
              // ProductOverviewScreen.routeName: (context) => ProductOverviewScreen(),
              ProductDetail.routeName: (context) => ProductDetail(),
              CartScreen.routeName: (context) => CartScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              UserProductScreen.routeName: (context) => UserProductScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
          ),
        ));
  }
}
