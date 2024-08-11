import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopy/provider/auth_provider.dart';
import '../screens/orders_screen.dart';
import '../screens/product_overview_screen.dart';
import '../screens/user_product_screen.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('No'),
          )
        ],
        content: Text('you wanna logout'),
      ),
    );
  }

  // Helper method to create ListTile widgets
  ListTile _createListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      textColor: Colors.deepPurple,
      leading: Icon(
        icon,
        color: Colors.deepPurple, // Set icon color
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<AuthProvider>(context, listen: false).email;
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 46, 14, 100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    _showDialog(context);
                  },
                  child: CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      userEmail != null && userEmail.isNotEmpty
                          ? userEmail[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 28.0,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  userEmail ?? 'Not Logged In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _createListTile(
            icon: Icons.shop,
            title: 'Shop',
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ProductOverviewScreen(),
                ),
              );
            },
          ),
          _createListTile(
            icon: Icons.list,
            title: 'Orders',
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
          _createListTile(
            icon: Icons.edit,
            title: 'Products',
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductScreen.routeName);
            },
          ),
          _createListTile(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              _showDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
