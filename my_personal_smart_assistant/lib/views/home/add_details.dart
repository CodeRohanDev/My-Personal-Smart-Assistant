// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, prefer_const_constructors, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_personal_smart_assistant/providers/auth_provider.dart'
    as my_provider;

class AddDetailsPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  // Add more controllers for other details as needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(
                labelText: 'Age',
              ),
              keyboardType: TextInputType.number,
            ),
            // Add more fields for other details as needed
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveDetails(context);
              },
              child: Text('Save Details'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDetails(BuildContext context) async {
    final authProvider = Provider.of<my_provider.AuthProvider>(context,
        listen: false); // Use the correct AuthProvider
    try {
      User? currentUser = authProvider.user;
      if (currentUser != null) {
        await currentUser.updateProfile(
          displayName: nameController.text,
        );
        // Add more updates for other details as needed
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Handle error saving details
      print('Error saving user details: $e');
    }
  }
}
