import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:receipt_validator/core/constants.dart';
import 'package:flutter/gestures.dart';

class LoginPage extends StatefulWidget {
  static String route = 'login-page';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  bool _emailTouched = false;
  bool _passwordTouched = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _emailTouched = true;
        _validateEmail();
      });
    });
    _passwordController.addListener(() {
      setState(() {
        _passwordTouched = true;
        _validatePassword();
      });
    });

    GetStorage.init();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    if (_emailTouched) {
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
  }

  void _validatePassword() {
    final password = _passwordController.text;
    if (_passwordTouched) {
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
  }

  bool get _isFormValid {
    return _emailError == null &&
        _passwordError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _signIn() async {
    if (_isFormValid) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Store email in GetStorage
        final box = GetStorage();
        box.write('user_email', _emailController.text.trim());

        Get.toNamed('mainscreen-page');
      } on FirebaseAuthException catch (e) {
        String errorMessage =
            'The email or password is invalid or check your internet connection';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        }
        Get.snackbar('Login Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Ensure the user is signed out from Google Sign-In
      await _googleSignIn.signOut();

      // Force account selection
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in process
        return;
      }

      // Authenticate with Firebase
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Store user email in GetStorage
      final box = GetStorage();
      box.write('user_email', userCredential.user?.email);

      // Navigate to the main screen
      Get.toNamed('mainscreen-page');
    } catch (e) {
      Get.snackbar('Google Sign-In Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
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
                    mainAxisSize: MainAxisSize.max,
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
                                Row(
                                  children: [
                                    Text(
                                      'Welcome',
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      width: 30,
                                      height: 30,
                                      child: Image.asset(
                                        'assets/images/hi.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'to',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      ' Receipt validator',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w500,
                                        color: AppConstants.darkblue,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Hello there, Sign up to continue',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                SizedBox(height: 30),
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
                                        'Email Address',
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
                                Stack(
                                  children: [
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: null,
                                        errorText: _passwordError,
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
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      onChanged: (value) {
                                        _validatePassword();
                                      },
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
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
                                GestureDetector(
                                  onTap: _isFormValid ? _signIn : null,
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
                                        padding: EdgeInsets.all(18.0),
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                GestureDetector(
                                  onTap: _signInWithGoogle,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(18.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/google_logo.png',
                                              height: 24,
                                              width: 24,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'Sign in with Google',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
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
                            text: "Don't have an account? ",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Create one',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppConstants.darkblue,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.toNamed('signup-page');
                                    }),
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
