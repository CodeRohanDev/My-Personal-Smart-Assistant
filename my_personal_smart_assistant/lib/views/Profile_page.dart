// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: userData == null
            ? CircularProgressIndicator(color: Colors.blue)
            : ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(
                        userData?['Personal Details']?['ProfilePicture'] ??
                            'https://via.placeholder.com/150',
                        headers: {'Cache-Control': 'no-cache'},
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "${userData?['Personal Details']?['Name'] ?? 'N/A'}",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ProfileDetail(
                    title: "Age",
                    value: userData?['Personal Details']?['Age'],
                  ),
                  ProfileDetail(
                    title: "Gender",
                    value: userData?['Personal Details']?['Gender'],
                  ),
                  ProfileDetail(
                    title: "Height",
                    value: userData?['Personal Details']?['Height'],
                  ),
                  ProfileDetail(
                    title: "Weight",
                    value: userData?['Personal Details']?['Weight']?['Kg'],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Sign Out",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfilePage(userData: userData),
                        ),
                      );
                    },
                    child: Text("Edit Profile"),
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                      side: BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ProfileDetail extends StatelessWidget {
  final String title;
  final dynamic value;

  const ProfileDetail({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline),
          SizedBox(width: 12),
          Text(
            "$title: ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8),
          Text(
            value?.toString() ?? 'N/A',
            style: TextStyle(
              fontSize: 18,
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
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: Text("Edit Profile Page (To be implemented)"),
      ),
    );
  }
}
