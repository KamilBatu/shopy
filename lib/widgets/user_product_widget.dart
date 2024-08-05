import 'package:flutter/material.dart';
import '../screens/edit_product_screen.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';

class UserProductWidget extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  UserProductWidget(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(title),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 96, // Adjust width as needed
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                Navigator.popAndPushNamed(
                  context,
                  EditProductScreen.routeName,
                  arguments: id,
                );
                print(id);
              },
              icon: Icon(
                Icons.edit,
                color: Colors.deepPurple,
              ),
            ),
            IconButton(
              onPressed: () async {
                try {
                  await Provider.of<ProductProvider>(context, listen: false)
                      .deleteProduct(id);
                } catch (e) {
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('couldnot delete item'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              icon: Icon(
                Icons.delete,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
