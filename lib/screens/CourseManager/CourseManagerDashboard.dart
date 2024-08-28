import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseManagerDashboard extends StatefulWidget {
  @override
  _CourseManagerDashboardState createState() => _CourseManagerDashboardState ();
}

class _CourseManagerDashboardState  extends State<CourseManagerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Manager Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login'); // Adjust route as needed
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['email']),
                subtitle: Text('Role: ${user['role']}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      await _firestore.collection('users').doc(user.id).delete();
                    } else if (value == 'promote') {
                      await _firestore.collection('users').doc(user.id).update({'role': 'admin'});
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'promote',
                      child: Text('Promote to Admin'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete User'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
