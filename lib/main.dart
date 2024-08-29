import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_mcq/screens/Admin/categories/categorieshomescreen.dart';
import 'package:flutter_mcq/screens/Admin/courses/add_course_page.dart';
import 'package:flutter_mcq/screens/Admin/courses/coursehomescreen.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Set the initial route to the login page
      routes: {
        '/admin': (context) => AdminDashboard(),
        '/course_manager': (context) => CourseManagerDashboard(),
        '/home': (context) => ClientDashboard(), //user dashboard
        '/auth_check': (context) => AuthCheck(), //role checking route
        '/login': (context) => Loginpage(), //the login page route
        '/categories':(context) => CategoriesPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/courses') {
          final args = settings.arguments as Map<String, String>;
          final subcategoryId = args['subcategoryId'] ?? '';

           return MaterialPageRoute(
            builder: (context) => CoursesPage(subcategoryId: subcategoryId),
          );
        } else if (settings.name == '/add_course') {
          final args = settings.arguments as Map<String, String>;
          final subcategoryId = args['subcategoryId'] ?? '';

          return MaterialPageRoute(
            builder: (context) => AddCoursePage(subcategoryId: subcategoryId),
          );
        }
        // Handle other routes if necessary
        return null;
      },
    );
  }
}