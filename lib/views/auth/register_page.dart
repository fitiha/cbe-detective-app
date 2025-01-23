import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:receipt_validator/core/constants.dart';
import 'package:flutter/gestures.dart';

class RegisterPage extends StatefulWidget {
  static String route = 'signup-page';

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email';
      });
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Please enter your password';
      });
    } else if (password.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters long';
      });
    } else if (password.length > 64) {
      setState(() {
        _passwordError = 'Password must be no longer than 64 characters';
      });
    } else if (!RegExp(
            r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])')
        .hasMatch(password)) {
      setState(() {
        _passwordError = 'Must include at least one:'
            '\n• Uppercase letter (A-Z)'
            '\n• Lowercase letter (a-z)'
            '\n• Number (0-9)'
            '\n• Special character (!@#\$%^&* etc.)';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

  void _validateConfirmPassword() {
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword != _passwordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }
  }

  bool get _isFormValid {
    return _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _register() async {
    if (_isFormValid) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Get.toNamed('mainscreen-page');
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred during registration.';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already registered.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Password is too weak.';
        }
        Get.snackbar('Registration Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    height: 100,
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Register to start using the app',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                SizedBox(height: 30),
                                // Email Field
                                Stack(
                                  children: [
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: null,
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 25, horizontal: 10),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 227, 227, 227),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                            width: 2.0,
                                          ),
                                        ),
                                        errorText: _emailError,
                                      ),
                                      onChanged: (value) {
                                        _validateEmail();
                                      },
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Positioned(
                                      left: 10,
                                      top: 8,
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                          color: _emailController.text.isEmpty
                                              ? Colors.black
                                              : Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                // Password Field
                                Stack(
                                  children: [
                                    TextFormField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        labelText: null,
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 25, horizontal: 10),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 227, 227, 227),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                            width: 2.0,
                                          ),
                                        ),
                                        errorText: _passwordError,
                                      ),
                                      onChanged: (value) {
                                        _validatePassword();
                                      },
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                      obscureText: _obscurePassword,
                                    ),
                                    Positioned(
                                      left: 10,
                                      top: 8,
                                      child: Text(
                                        'Password',
                                        style: TextStyle(
                                          color:
                                              _passwordController.text.isEmpty
                                                  ? Colors.black
                                                  : Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                // Confirm Password Field
                                Stack(
                                  children: [
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      decoration: InputDecoration(
                                        labelText: null,
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 25, horizontal: 10),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 227, 227, 227),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.blue,
                                            width: 2.0,
                                          ),
                                        ),
                                        errorText: _confirmPasswordError,
                                      ),
                                      onChanged: (value) {
                                        _validateConfirmPassword();
                                      },
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                      obscureText: _obscurePassword,
                                    ),
                                    Positioned(
                                      left: 10,
                                      top: 8,
                                      child: Text(
                                        'Confirm Password',
                                        style: TextStyle(
                                          color: _confirmPasswordController
                                                  .text.isEmpty
                                              ? Colors.black
                                              : Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20),
                                // Register Button
                                GestureDetector(
                                  onTap: _isFormValid ? _register : null,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: _isFormValid
                                          ? AppConstants.darkblue
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Text(
                                          'Register',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text.rich(
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: AppConstants.darkblue,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.toNamed("login-page");
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
