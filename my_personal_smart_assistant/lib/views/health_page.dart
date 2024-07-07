// ignore_for_file: prefer_const_constructors, prefer_const_declarations, avoid_print, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference userRef;
  Map<String, dynamic>? userData;
  String? healthReport;
  String? errorMessage;

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
        generateHealthReport(); // Call the function to generate the health report
      } else {
        userData = {};
      }
    });
  }

  Future<void> generateHealthReport() async {
    if (userData != null) {
      final personalDetails = userData!['Personal Details'];
      final diseaseDetails = userData!['Disease Details'];

      final requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': '''
Generate a health report based on the following details:
Name: ${personalDetails?['Name'] ?? 'N/A'}
Age: ${personalDetails?['Age'] ?? 'N/A'}
Height: ${personalDetails?['Height'] ?? 'N/A'}
Weight: ${personalDetails?['Weight']?['Kg'] ?? 'N/A'}
Diseases: ${diseaseDetails != null ? (diseaseDetails as List).map((disease) => "Type: ${disease['type']}, Stage: ${disease['stage']}").join('; ') : 'None'}
'''
              }
            ],
          }
        ],
      };

      try {
        final url =
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyAgI-ndEh8HwLu712uruo-qb8P86tOctYY';
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          print('Response from AI: $jsonResponse');
          if (jsonResponse != null && jsonResponse.containsKey('candidates')) {
            final candidates = jsonResponse['candidates'];
            if (candidates.isNotEmpty &&
                candidates[0].containsKey('content') &&
                candidates[0]['content'].containsKey('parts') &&
                candidates[0]['content']['parts'].isNotEmpty) {
              setState(() {
                healthReport = candidates[0]['content']['parts'][0]['text'];
                // Remove the unusual stars here
                healthReport = healthReport?.replaceAll('**', '');
                errorMessage = null;
              });
            } else {
              setState(() {
                healthReport = 'Error: AI response is empty or malformed.';
              });
            }
          } else {
            setState(() {
              healthReport = 'Error: AI response is empty or malformed.';
            });
          }
        } else {
          print('Error response: ${response.body}');
          setState(() {
            healthReport =
                'Error: Unable to fetch response from AI. Status Code: ${response.statusCode}';
          });
        }
      } catch (e) {
        print('Exception occurred: $e');
        setState(() {
          healthReport =
              'Error: Exception occurred while fetching response from AI.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Page"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: userData == null
            ? CircularProgressIndicator(color: Colors.blue)
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Details",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 10),
                        ProfileDetail(
                          title: "Name",
                          value:
                              userData?['Personal Details']?['Name'] ?? 'N/A',
                        ),
                        ProfileDetail(
                          title: "Age",
                          value: userData?['Personal Details']?['Age'] ?? 'N/A',
                        ),
                        ProfileDetail(
                          title: "Height",
                          value:
                              userData?['Personal Details']?['Height'] ?? 'N/A',
                        ),
                        ProfileDetail(
                          title: "Weight",
                          value: userData?['Personal Details']?['Weight']
                                  ?['Kg'] ??
                              'N/A',
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Disease Details",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 10),
                        userData?['Disease Details'] != null
                            ? Column(
                                children: (userData!['Disease Details'] as List)
                                    .map((item) => DiseaseDetail(
                                          type: item['type'],
                                          stage: item['stage'],
                                        ))
                                    .toList(),
                              )
                            : Text("No disease details available."),
                        SizedBox(height: 20),
                        Text(
                          "Health Report",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 10),
                        healthReport != null
                            ? Text(
                                healthReport!,
                                style: TextStyle(fontSize: 16),
                              )
                            : errorMessage != null
                                ? Text(
                                    errorMessage!,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.red),
                                  )
                                : Text("Generating health report..."),
                      ],
                    ),
                  ),
                ),
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
        children: [
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

class DiseaseDetail extends StatelessWidget {
  final String type;
  final String stage;

  const DiseaseDetail({required this.type, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Type: $type",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Stage: $stage",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
