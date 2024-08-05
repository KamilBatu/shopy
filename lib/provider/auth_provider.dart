import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  Future<void> authenticate(
      String email, String password, String segment) async {
    final baseUrl =
        'https://identitytoolkit.googleapis.com/v1/accounts:$segment?key=AIzaSyBk1LU62j0FNdSxAYNuYSvF_HKIyVKALcE';
    try {
      final url = Uri.parse(baseUrl); // Corrected URI conversion
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }),
          headers: {
            'Content-Type': 'application/json'
          }); // Ensure correct headers are set
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print(responseData);
        // Handle successful signup (e.g., store token, navigate to another screen)
      } else {
        // Handle errors, e.g., invalid email, weak password, etc.
        print("Error: ${responseData['error']['message']}");
        throw Exception(responseData['error']['message']);
      }
    } catch (e) {
      print("An error occurred: $e");
      throw e; // Rethrow the error after logging it
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    return authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }
}
