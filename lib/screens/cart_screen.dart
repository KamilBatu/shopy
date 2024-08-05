import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopy/provider/cart_provider.dart';
import 'package:shopy/provider/orders_provider.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cartItems = Provider.of<CartProvider>(context);
    final orderItems = Provider.of<OrdersProvider>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'YOur Cart',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Card(
            elevation: 5,
            child: ListTile(
              leading: Text(
                'TOtal',
                style: TextStyle(color: Colors.deepPurple, fontSize: 20),
              ),
              title: Chip(
                // avatar: CircleAvatar(
                //   backgroundColor: Color.fromARGB(255, 19, 70, 137),
                //   child: const Text('AB'),
                // ),
                avatar: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Center(
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                label: Text(
                  '${cartItems.totalPrice().toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                backgroundColor: Colors.deepPurple,
                side: BorderSide(style: BorderStyle.none),
              ),
              tileColor: Colors.white,
              trailing: OrderButton(
                cartItems: cartItems,
                orderItems: orderItems,
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: cartItems.cartItem.length,
            itemBuilder: (context, index) {
              return Dismissible(
                background: Container(
                  color: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                key: ValueKey(cartItems.cartItem.values.toList()[index].id),
                child: CartItemWidget(
                  cartItems.cartItem.values.toList()[index].id,
                  cartItems.cartItem.values.toList()[index].title,
                  cartItems.cartItem.values.toList()[index].imageUrl,
                  cartItems.cartItem.values.toList()[index].price,
                  cartItems.cartItem.values.toList()[index].quantity,
                  cartItems.cartItem.keys.toList()[index],
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) {
                  return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: Text('are you sure?'),
                            content: Text(
                                'are you sure about deleting this all product'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop(true);
                                },
                                child: Text('yes'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop(false);
                                },
                                child: Text('no'),
                              )
                            ],
                          ));
                },
                onDismissed: (direction) {
                  cartItems.removeItem(cartItems.cartItem.keys.toList()[index]);
                },
              );
            },
          ))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    super.key,
    required this.cartItems,
    required this.orderItems,
  });

  final CartProvider cartItems;
  final OrdersProvider orderItems;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: widget.cartItems.totalPrice() <= 0
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                await widget.orderItems.addOrder(
                  widget.cartItems.totalPrice(),
                  DateTime.now(),
                  widget.cartItems.cartItem.values.toList(),
                );
                setState(() {
                  _isLoading = false;
                });
                widget.cartItems.clearCart();
              },
        label: _isLoading
            ? CircularProgressIndicator()
            : Text(
                'Order Now',
                style: TextStyle(color: Colors.deepPurple, fontSize: 18),
              ));
  }
}
