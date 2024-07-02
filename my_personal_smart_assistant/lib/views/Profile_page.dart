// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference userRef;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userRef = FirebaseDatabase.instance.ref().child('Users/${user!.uid}');
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    DataSnapshot snapshot = await userRef.get();
    setState(() {
      if (snapshot.value != null) {
        userData = Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        userData = {};
      }
      print(userData); // Check the structure here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
      ),
      body: user == null
          ? Center(
              child: Text("No user signed in"),
            )
          : userData == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            userData?['Personal Details']?['ProfilePicture'] ??
                                'https://via.placeholder.com/150',
                            headers: {'Cache-Control': 'no-cache'},
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${userData?['Personal Details']?['Name'] ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: Text("Edit Profile"),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        buildProfileDetail(
                            "Age", userData?['Personal Details']?['Age']),
                        buildProfileDetail(
                            "Gender", userData?['Personal Details']?['Gender']),
                        buildProfileDetail(
                            "Height", userData?['Personal Details']?['Height']),
                        buildProfileDetail(
                          "Weight",
                          userData?['Personal Details']?['Weight']?['Kg'],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          },
                          child: Text("Sign Out"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget buildProfileDetail(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 16),
          Text(
            "$title: ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  final Map<String, dynamic>? userData;

  EditProfilePage({this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Center(
        child: Text("Edit Profile Page (To be implemented)"),
      ),
    );
  }
}
