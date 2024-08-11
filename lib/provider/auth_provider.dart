import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;
  String? _email;

  String? get email => _email;

  bool get isAuth => token != null;

  String? get userId => _userId;

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    _email = null; // Clear email on logout

    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    notifyListeners();
  }

  void _autologout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    if (_expiryDate != null) {
      final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    }
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> authenticate(
      String email, String password, String segment) async {
    final baseUrl =
        'https://identitytoolkit.googleapis.com/v1/accounts:$segment?key=AIzaSyBk1LU62j0FNdSxAYNuYSvF_HKIyVKALcE';
    try {
      final url = Uri.parse(baseUrl);
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }),
          headers: {'Content-Type': 'application/json'});
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        print("Error: ${responseData['error']['message']}");
        throw HttpException(responseData['error']['message']);
      } else {
        _token = responseData['idToken'];
        _userId = responseData['localId'];
        _expiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(responseData['expiresIn'])));
        if (segment == 'signInWithPassword') {
          _email = responseData['email'];
        }
        print(responseData);
      }
    } catch (e) {
      print("An error occurred: $e");
      throw e;
    }
    _autologout();

    // Save user data to shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'expiryDate': _expiryDate?.toIso8601String(),
      'userId': _userId,
      'email': _email, // Save email to shared preferences
    });
    await prefs.setString('userData', userData);

    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final userDataString = prefs.getString('userData');
    if (userDataString == null) {
      return false;
    }

    final extractedUserData =
        json.decode(userDataString) as Map<String, dynamic>;
    final prefsExpiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (prefsExpiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _expiryDate = prefsExpiryDate;
    _userId = extractedUserData['userId'];
    _email =
        extractedUserData['email']; // Retrieve email from shared preferences

    notifyListeners();
    _autologout();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    return authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }
}
