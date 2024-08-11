import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopy/provider/auth_provider.dart';
import 'package:shopy/widgets/loading.dart';
import '../models/http_exception.dart';

enum AuthMode {
  login,
  signup,
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'auth',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: AuthCard(),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  var _isLoading = false;
  var _isPasswordVisible = false;
  TextEditingController _passwordController = TextEditingController();
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _passwordController = TextEditingController();
    super.initState();
  }

  AuthMode _authMode = AuthMode.login;
  var _textButton = 'sign up instead';
  var _elevetedButton = 'login';
  void switchButton() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
        _textButton = 'login instead';
        _elevetedButton = 'sign up';
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
        _textButton = 'sign up instead';
        _elevetedButton = 'login';
      });
    }
  }

  void _showErrorDialog(errorMessage) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Okay'))
              ],
              content: Text(errorMessage),
              title: Text('error Occured'),
            ));
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<AuthProvider>(context, listen: false)
            .login(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<AuthProvider>(context, listen: false)
            .signUp(_authData['email']!, _authData['password']!);
      }
      // Handle login or other modes if necessary
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage =
            'There is no user record corresponding to this identifier';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'The password is invalid';
      } else if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage =
            'The email address is already in use by another account.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'The email address is badly formatted';
      } else if (error.toString().contains('USER_NOT_FOUND')) {
        errorMessage =
            'There is no user record corresponding to this identifier';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'The password must be 6 characters long or more';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'The password must be 6 characters long or more';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Couldnot authenticate you. please try again later';
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _isLoading
          ? Center(
              child: LinearProgressIndicator(
              color: Colors.deepPurple,
            ))
          : Column(
              children: [
                Center(
                    child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Text(
                    'Welcome to shopy',
                    style: TextStyle(color: Colors.deepPurple, fontSize: 32),
                  ),
                )),
                Card(
                  margin: EdgeInsets.all(20),
                  shadowColor: const Color.fromARGB(255, 200, 190, 218),
                  elevation: 14,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: TextFormField(
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'can\'t be empty';
                                }

                                if (!value.contains('@') ||
                                    !value.endsWith('.com') ||
                                    value.length <= 8) {
                                  return 'invalid email';
                                }
                              },
                              decoration: InputDecoration(
                                label: Text('email'),
                              ),
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocusNode);
                              },
                              onSaved: (value) {
                                _authData['email'] = value!;
                              }),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: TextFormField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'password field is empty';
                              }
                              if (value!.length < 6) {
                                return 'password is too short';
                              }
                            },
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              label: Text('password'),
                            ),
                            focusNode: _passwordFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_confirmPasswordFocusNode);
                            },
                            onSaved: (value) {
                              _authData['password'] = value!;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (_authMode != AuthMode.login)
                          Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'password field is empty';
                                }
                                if (value.length < 6) {
                                  return 'password is too short';
                                }
                                if (value != _passwordController.text) {
                                  return 'not match';
                                }
                              },
                              obscureText: !_isPasswordVisible,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                label: Text('confirm password'),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              focusNode: _confirmPasswordFocusNode,
                              onSaved: (value) {
                                _authData['password'] = value!;
                              },
                            ),
                          ),
                        SizedBox(
                          height: 40,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _saveForm();
                          },
                          child: Text(
                            _elevetedButton,
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.deepPurple),
                              elevation: WidgetStatePropertyAll(16)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          onPressed: () {
                            switchButton();
                          },
                          child: Text(_textButton),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
