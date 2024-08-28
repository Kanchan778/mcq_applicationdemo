import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Login a user or admin
  Future<User?> login(String email, String password) async {
    try {
      // Check if email and password match admin credentials from Firestore
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
      QuerySnapshot snapshot = await _firestore.collection('admin_credentials').where('email', isEqualTo: email).get();

      if (snapshot.docs.isEmpty) {
        return false; // No admin credentials found for this email
      }

      DocumentSnapshot adminDoc = snapshot.docs.first;
      String storedPassword = adminDoc['password']; // Assuming password is stored in plaintext (consider hashing passwords)

      return password == storedPassword;
    } catch (e) {
      print('Error checking admin credentials: $e');
      return false;
    }
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
}
