import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart'; // For hashing passwords
import 'dart:convert'; // For encoding

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user with additional data and the 'client' role
  Future<User?> register(String email, String password, String name, String address) async {
    try {
      // Register the user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'role': 'client',  // Default role for new users
        'name': name,      // Additional user data
        'address': address, // Additional user data
        'email': email,    // Store email for reference
      });

      return userCredential.user;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // Function to add admin credentials with role
  Future<void> addAdminCredentials(String email, String password) async {
    try {
      // Hash the password before storing
      String hashedPassword = _hashPassword(password);

      // Store the admin credentials and role in Firestore
      await _firestore.collection('admin_credentials').doc(email).set({
        'email': email,
        'password': hashedPassword,
        'role': 'admin', // Set the role as admin
      });

      print('Admin credentials added successfully.');
    } catch (e) {
      print('Error adding admin credentials: $e');
    }
  }

  // Login a user or admin
  Future<User?> login(String email, String password) async {
    try {
      // Check if the credentials match admin credentials
      bool isAdmin = await _isAdmin(email, password);

      if (isAdmin) {
        // Admin login
        UserCredential adminCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return adminCredential.user;
      } else {
        // Regular user login
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return userCredential.user;
      }
    } catch (e) {
      print('Error logging in user: $e');
      return null;
    }
  }

  // Check if the email and password match admin credentials
  Future<bool> _isAdmin(String email, String password) async {
    try {
      // Fetch admin credentials from Firestore
      DocumentSnapshot adminDoc = await _firestore.collection('admin_credentials').doc(email).get();

      if (!adminDoc.exists) {
        return false; // No admin credentials found for this email
      }

      // Retrieve the stored hashed password
      String storedHashedPassword = adminDoc['password'];

      // Hash the provided password and compare
      String hashedPassword = _hashPassword(password);
      return hashedPassword == storedHashedPassword;
    } catch (e) {
      print('Error checking admin credentials: $e');
      return false;
    }
  }

  // Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    final digest = sha256.convert(bytes); // Hash password
    return digest.toString(); // Convert hash to string
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser; // Return the current user wrapped in a Future
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Optional: Clear any additional state or local storage here
    } catch (e) {
      print('Sign out error: $e');
      // Handle sign out error (e.g., show a dialog or message)
    }
  }

  // Get user role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc['role'] as String?;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }

  // Get additional user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  //store catgeories data
  Future<void> addCategory(String name, String description) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    // Store category data in Firestore
    await _firestore.collection('categories').add({
      'Category Name': name,            // Category name
      'category Description': description, // Category description
    });
    print('Category added successfully');
  } catch (e) {
    print('Error adding category: $e');
  }
}
 // Fetch category names
  Future<List<String>> getCategoryNames() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      return querySnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>?; 
          return data?['Category Name'] as String? ?? 'No Category Name'; 
        })
        .where((categoryName) => categoryName.isNotEmpty) 
        .toList();
    } catch (e) {
      print('Error fetching category names: $e');
      return [];
    }
  }
}

