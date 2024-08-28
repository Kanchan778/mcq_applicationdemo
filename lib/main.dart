import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_mcq/screens/Admin/dashboardScreen.dart';
import 'package:flutter_mcq/screens/Clients/ClientDashboard.dart';
import 'package:flutter_mcq/screens/CourseManager/CourseManagerDashboard.dart';
import 'package:flutter_mcq/screens/loginpage.dart';
import 'package:flutter_mcq/services/authcheck.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Role-Based Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Loginpage(), // login & signup route
      routes: {
        '/admin': (context) => AdminDashboard(),
        '/course_manager': (context) => CourseManagerDashboard(), // coursemanager dashboard route
        '/home': (context) => ClientDashboard(), // clientdashboard route
        '/auth_check': (context) => AuthCheck(), // AuthCheck route
        
      }
    );
  }
}

