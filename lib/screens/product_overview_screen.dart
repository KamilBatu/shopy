import 'package:flutter/material.dart';
import 'package:shopy/provider/cart_provider.dart';
import '../provider/product_provider.dart';
import 'package:shopy/screens/cart_screen.dart';
import '../widgets/drawer.dart';
import 'package:shopy/widgets/gridview_widget.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import '../widgets/loading.dart';

enum SelectedOption {
  ShowAll,
  OnlyFav,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var filter = false;
  var _initDid = true;
  var _isLoading = true;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_initDid) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductProvider>(context).fetchAndSet().then(
        (_) {
          setState(() {
            _isLoading = false;
          });
        },
      ).catchError((error) {
        print('something is not right');
      });
    }
    _initDid = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text(
          'shopy',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (SelectedOption selectedOption) {
              if (selectedOption == SelectedOption.OnlyFav) {
                setState(() {
                  filter = true;
                });
              } else {
                setState(() {
                  filter = false;
                });
              }
            },
            icon: Icon(
              Icons.more_vert_outlined,
              size: 30,
              color: Colors.white,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text(
                  'show ALL',
                  style: TextStyle(color: Colors.deepPurple),
                ),
                value: SelectedOption.ShowAll,
              ),
              PopupMenuItem(
                child: Text(
                  'Favorite',
                  style: TextStyle(color: Colors.deepPurple),
                ),
                value: SelectedOption.OnlyFav,
              )
            ],
          ),
          // badge
          Padding(
            padding: const EdgeInsets.all(10),
            child: badges.Badge(
              onTap: () =>
                  Navigator.of(context).pushNamed(CartScreen.routeName),
              badgeStyle: badges.BadgeStyle(badgeColor: Colors.pink),
              badgeContent: Consumer<CartProvider>(
                builder: (context, value, child) => Text(
                  '${value.items()}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              child: Icon(
                Icons.shopping_cart,
                size: 26,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: _isLoading ? Loading('loading...') : GridviewWidget(filter),
    );
  }
}
