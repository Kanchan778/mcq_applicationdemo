import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_mcq/screens/Clients/ClientDashboard.dart';
import 'package:flutter_mcq/screens/CourseManager/CourseManagerDashboard.dart';
import 'package:flutter_mcq/services/authservices.dart';
import 'package:flutter_mcq/screens/Admin/dashboardScreen.dart';
import 'package:flutter_mcq/screens/loginpage.dart';
//import 'package:flutter_mcq/screens/courseManagerDashboard.dart'; // Import as needed
//import 'package:flutter_mcq/screens/homepage.dart'; // Import as needed

class AuthCheck extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _authService.getCurrentUser(), // Get current user
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while checking authentication
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasData && userSnapshot.data != null) {
          // User is logged in, check their role
          return FutureBuilder<String?>(
            future: _authService
                .getUserRole(userSnapshot.data!.uid), // Fetch user role
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                // Show a loading spinner while fetching the role
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasData) {
                String role = roleSnapshot.data!;
                switch (role) {
                  case 'admin':
                    return AdminDashboard(); // Navigate to the admin dashboard
                  case 'course_manager':
                    return CourseManagerDashboard(); // Replace with actual widget
                  default:
                    return ClientDashboard(); // Replace with actual home page widget
                }
              } else {
                // Role fetching failed or data is null, handle accordingly
                return Loginpage(); // Or a screen that indicates a problem
              }
            },
          );
        } else {
          // User is not logged in, show the login page
          return Loginpage();
        }
      },
    );
  }
}
