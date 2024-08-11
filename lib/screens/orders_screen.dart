import 'package:flutter/material.dart';
import 'package:shopy/provider/orders_provider.dart';
import '../widgets/loading.dart';
import '../widgets/drawer.dart';
import 'package:provider/provider.dart';
import '../widgets/order_widget.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders-screen';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<OrdersProvider>(context, listen: false).fetchAndSet();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvided = Provider.of<OrdersProvider>(context);
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text(
          'Orders',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? Loading('fetching orders...')
          : ordersProvided.ordersList.isEmpty
              ? Center(
                  child: Text(
                    'No orders found.',
                    style: TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  itemCount: ordersProvided.ordersList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return OrderWidget(ordersProvided.ordersList[index]);
                  },
                ),
    );
  }
}
