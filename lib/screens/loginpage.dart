import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_mcq/controllers/authcontrollers.dart';
import 'package:flutter_mcq/services/authservices.dart';
import 'package:flutter_mcq/utils/colors.dart'; // Import your colors file
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Loginpage extends StatefulWidget {
  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; // Toggle between login and signup

  final AuthControllers _controllers = AuthControllers();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      String email = _controllers.emailController.text;
      String password = _controllers.passwordController.text;

      try {
        if (_isLogin) {
          // Login with email and password
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          User? user = userCredential.user;
          if (user != null) {
            // Fetch the user's role from Firestore
            DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
            Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

            String role = data?['role'] ?? 'client'; // Default role if not found

            // Navigate based on role
            Navigator.pushReplacementNamed(
              context,
              role == 'admin'
                  ? '/admin'
                  : role == 'course_manager'
                      ? '/course_manager'
                      : '/home',
            );
          }
        } else {
          // Signup with email and password
          User? user = await _authService.register(
            email,
            password,
            _controllers.nameController.text,
            _controllers.addressController.text,
          );

          if (user != null) {
            // Determine role and store in Firestore
            String role = email == 'admin@example.com' ? 'admin' : 'client';

            // Store additional user details in Firestore
            await _firestore.collection('users').doc(user.uid).set({
              'email': email,
              'role': role,
            }, SetOptions(merge: true));

            _showDialog('Success', 'Successfully registered! Please log in.');
            // Navigate to login page after successful registration
            Future.delayed(Duration(seconds: 1), () {
              Navigator.pushReplacementNamed(context, '/login');
            });
          } else {
            _showDialog('Error', 'Registration failed.');
          }
        }
      } catch (e) {
        // Handle login/signup error
        print('Login error: $e');
        _showDialog('Error', 'An error occurred: ${e.toString()}');
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          // Fetch the user's role from Firestore
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

          String role = data?['role'] ?? 'client'; // Default role if not found

          // Navigate based on role
          Navigator.pushReplacementNamed(
            context,
            role == 'admin'
                ? '/admin'
                : role == 'course_manager'
                    ? '/course_manager'
                    : '/home',
          );
        }
      }
    } catch (error) {
      print('Google sign-in error: $error');
      _showDialog('Error', 'Failed to sign in with Google: ${error.toString()}');
    }
  }

  void _signInWithFacebook() {
    // Implement Facebook Sign-In
    print('Sign in with Facebook');
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Signup'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 300, // Width of the container
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // Background color of the container
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  offset: Offset(0, 2), // Shadow position
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _controllers.nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _controllers.addressController,
                          decoration: const InputDecoration(labelText: 'Address'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _controllers.emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controllers.passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _register,
                        child: Text(_isLogin ? 'Login' : 'Signup'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _toggleForm,
                  child: Text(_isLogin ? 'Don\'t have an account? Signup' : 'Already have an account? Login'),
                ),
                const SizedBox(height: 20),
                const Text('Or'),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    iconColor: primaryColor, // Google sign-in button color
                  ),
                  icon: const Icon(FontAwesomeIcons.google),
                  label: const Text('Sign in with Google'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _signInWithFacebook,
                  style: ElevatedButton.styleFrom(
                    iconColor: secondaryColor, // Facebook sign-in button color
                  ),
                  icon: const Icon(FontAwesomeIcons.facebookF),
                  label: const Text('Sign in with Facebook'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    _controllers.dispose();
    super.dispose();
  }
}
