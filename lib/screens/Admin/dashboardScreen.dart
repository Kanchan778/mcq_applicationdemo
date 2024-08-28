import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch total number of courses and users
  Future<int> _getTotalUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalCourses() async {
    final snapshot = await _firestore.collection('courses').get(); // Assuming 'courses' is the collection name
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            // Handle profile icon press
          },
        ),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Courses'),
              onTap: () {
                Navigator.pushNamed(context, '/courses'); // Adjust route as needed
              },
            ),
            ListTile(
              title: Text('Users'),
              onTap: () {
                Navigator.pushNamed(context, '/users'); // Adjust route as needed
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCountBox('Total Users', _getTotalUsers()),
                _buildCountBox('Total Courses', _getTotalCourses()),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
          ),
        ],
      ),
    );
  }

  Widget _buildCountBox(String title, Future<int> countFuture) {
    return FutureBuilder<int>(
      future: countFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return const Text('Error loading data');
        }

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                '${snapshot.data}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
