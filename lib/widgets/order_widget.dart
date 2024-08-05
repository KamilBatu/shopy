import 'dart:math';

import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderWidget extends StatefulWidget {
  final Order order;
  OrderWidget(this.order);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.totalAmount.toStringAsFixed(2)}'),
            subtitle: Text('${widget.order.orderedAt}'),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              padding: EdgeInsets.all(10),
              height: min(widget.order.ordersCartItems.length * 20 + 100, 180),
              child: ListView(
                children: widget.order.ordersCartItems.map((items) {
                  return ListTile(
                    title: Text(
                      items.title,
                    ),
                    trailing: Text('\$${items.price.toStringAsFixed(2)}'),
                  );
                }).toList(),
              ),
            )
        ],
      ),
    );
  }
}
