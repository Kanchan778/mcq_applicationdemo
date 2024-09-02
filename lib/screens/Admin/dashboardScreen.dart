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

  // Fetch total number of users
  Future<int> _fetchTotalUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.size; // Efficient way to get document count
    } catch (e) {
      print('Error fetching total users: $e');
      return 0;
    }
  }

  // Fetch total number of courses
  Future<int> _fetchTotalCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      return snapshot.size; // Efficient way to get document count
    } catch (e) {
      print('Error fetching total courses: $e');
      return 0;
    }
  }

  // Fetch total number of categories
  Future<int> _fetchTotalCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      return snapshot.size; // Efficient way to get document count
    } catch (e) {
      print('Error fetching total categories: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(
                  context, '/login'); // Adjust route as needed
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
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
                Navigator.pushNamed(context, '/courses',
                    arguments: {'subcategoryId': 'example_subcategory_id'});
              },
            ),
            ListTile(
              title: Text('Categories'),
              onTap: () {
                Navigator.pushNamed(context, '/categories');
              },
            ),
            ListTile(
              title: Text('Users'),
              onTap: () {
                Navigator.pushNamed(context, '/users');
              },
            ),
            ListTile(
              title: Text('Permission'),
              onTap: () {
                Navigator.pushNamed(context, '/userspermission');
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/adminsettings');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildCountBox('Total Users', _fetchTotalUsers()),
                    ),
                    SizedBox(width: 16), // Adjust spacing between items
                    Expanded(
                      child:
                          _buildCountBox('Total Courses', _fetchTotalCourses()),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildCountBox(
                          'Total Categories', _fetchTotalCategories()),
                    ),
                    SizedBox(width: 16), // Adjust spacing between items
                    Expanded(
                        child: Container()), // Maintains layout consistency
                  ],
                ),
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
                            await _firestore
                                .collection('users')
                                .doc(user.id)
                                .delete();
                          } else if (value == 'promote') {
                            await _firestore
                                .collection('users')
                                .doc(user.id)
                                .update({'role': 'admin'});
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
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Center(child: Text('Error loading data')),
          );
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
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
