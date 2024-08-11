import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String message;

  Loading(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  final String message;

  LoadingScreen(this.message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(color: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}
