import 'package:flutter/material.dart';

class AuthControllers {
  // Singleton pattern to ensure only one instance of controllers
  static final AuthControllers _instance = AuthControllers._internal();

  factory AuthControllers() {
    return _instance;
  }

  AuthControllers._internal();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController(); // Added for signup
  final TextEditingController addressController = TextEditingController(); // Added for signup

  // Dispose controllers when they are no longer needed
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose(); // Dispose of nameController
    addressController.dispose(); // Dispose of addressController
  }
}
