// ignore_for_file: prefer_const_constructors, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:my_personal_smart_assistant/main.dart';
import 'home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddDetailsScreen extends StatefulWidget {
  final User? user;
  AddDetailsScreen({this.user});

  @override
  _AddDetailsScreenState createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 0;
  String gender = 'Male';
  int height = 0;
  int weightKg = 0;
  int weightGm = 0;
  bool hasDiseaseDetails = false;
  List<Map<String, dynamic>> diseases = [];

  bool hasPetDetails = false;
  String petAnimalType = '';
  String petBreed = '';
  String petName = '';
  int petAgeMonth = 0;
  int petAgeYear = 0;
  String petGender = 'Male';
  int petWeightKg = 0;
  int petWeightGm = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Details')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfilePicturePicker(), // Add profile picture picker here
                  // Other form fields

                  // Remaining form fields
                ],
              ),
              // Personal details fields
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => name = value!,
              ),
              SizedBox(height: 12.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
                onSaved: (value) => age = int.parse(value!),
              ),
              SizedBox(height: 12.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                value: gender,
                items: ['Male', 'Female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    gender = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Height'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
                onSaved: (value) => height = int.parse(value!),
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Weight Kg'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight in Kg';
                        }
                        return null;
                      },
                      onSaved: (value) => weightKg = int.parse(value!),
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Weight Gm'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight in Gm';
                        }
                        return null;
                      },
                      onSaved: (value) => weightGm = int.parse(value!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.0),
              // Disease details fields
              CheckboxListTile(
                title: Text('Add Disease Details'),
                value: hasDiseaseDetails,
                onChanged: (value) {
                  setState(() {
                    hasDiseaseDetails = value!;
                  });
                },
              ),
              if (hasDiseaseDetails) ...[
                ...diseases.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> disease = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.0),
                      Text('Disease ${index + 1}'),
                      SizedBox(height: 12.0),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Type of Disease'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the type of disease';
                          }
                          return null;
                        },
                        onSaved: (value) => disease['type'] = value!,
                      ),
                      SizedBox(height: 12.0),
                      Column(
                        children: [
                          Text('Stage of Disease: '),
                          SizedBox(width: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    disease['stage'] = 'Low';
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: disease['stage'] == 'Low'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                child: Text('Low'),
                              ),
                              SizedBox(width: 12.0),
                              ElevatedButton(
                                onPressed: () {
                                  setState(
                                    () {
                                      disease['stage'] = 'Medium';
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: disease['stage'] == 'Medium'
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                                child: Text('Medium'),
                              ),
                              SizedBox(width: 12.0),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    disease['stage'] = 'High';
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: disease['stage'] == 'High'
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                child: Text('High'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
                SizedBox(height: 12.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      diseases.add({});
                    });
                  },
                  child: Text('Add Disease'),
                ),
                SizedBox(height: 12.0),
              ],
              // Pet details fields
              CheckboxListTile(
                title: Text('Add Pet Details'),
                value: hasPetDetails,
                onChanged: (value) {
                  setState(() {
                    hasPetDetails = value!;
                  });
                },
              ),
              if (hasPetDetails) ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Animal Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the animal type';
                    }
                    return null;
                  },
                  onSaved: (value) => petAnimalType = value!,
                ),
                SizedBox(height: 12.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Breed'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the pet breed';
                    }
                    return null;
                  },
                  onSaved: (value) => petBreed = value!,
                ),
                SizedBox(height: 12.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the pet name';
                    }
                    return null;
                  },
                  onSaved: (value) => petName = value!,
                ),
                SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Age (Months)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the pet age in months';
                          }
                          return null;
                        },
                        onSaved: (value) => petAgeMonth = int.parse(value!),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Age (Years)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the pet age in years';
                          }
                          return null;
                        },
                        onSaved: (value) => petAgeYear = int.parse(value!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Gender'),
                  value: petGender,
                  items: ['Male', 'Female'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      petGender = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the pet gender';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Weight Kg'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the pet weight in Kg';
                          }
                          return null;
                        },
                        onSaved: (value) => petWeightKg = int.parse(value!),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Weight Gm'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the pet weight in Gm';
                          }
                          return null;
                        },
                        onSaved: (value) => petWeightGm = int.parse(value!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
              ],
              ElevatedButton(
                onPressed: _saveDetails,
                child: Text('Save Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _saveImage(File imageFile) async {
    String userId = widget.user!.uid;
    String fileName = 'profile_picture.jpg';
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users')
        .child(userId)
        .child(fileName);

    try {
      // Upload image to Firebase Storage
      await ref.putFile(imageFile);

      // Get download URL
      String imageUrl = await ref.getDownloadURL();

      // Return the download URL to be saved in the database
      return imageUrl;
    } catch (e) {
      print('Error uploading image or saving URL: $e');
      // Handle error gracefully, e.g., show a snackbar or retry option
      throw e; // Re-throw the error to handle it further up the call stack
    }
  }

  Widget _buildProfilePicturePicker() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
          child: _imageFile == null
              ? Icon(Icons.person, size: 60, color: Colors.white)
              : null,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Pick Profile Picture'),
        ),
      ],
    );
  }

  _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('Users/${widget.user?.uid}');

      try {
        // Upload image if available
        if (_imageFile != null) {
          // Save image to Firebase Storage and get download URL
          String imageUrl = await _saveImage(_imageFile!);

          // Save personal details including image URL
          await ref.child('Personal Details').set({
            'Name': name,
            'Age': age,
            'Gender': gender,
            'Height': height,
            'Weight': {'Kg': weightKg, 'Gm': weightGm},
            'ProfilePicture': imageUrl, // Include the image URL here
          });
        } else {
          // Save personal details without image URL if no image was uploaded
          await ref.child('Personal Details').set({
            'Name': name,
            'Age': age,
            'Gender': gender,
            'Height': height,
            'Weight': {'Kg': weightKg, 'Gm': weightGm},
          });
        }

        // Save disease details if any
        if (hasDiseaseDetails) {
          List<Map<String, dynamic>> filteredDiseases =
              diseases.where((disease) => disease.isNotEmpty).toList();
          await ref.child('Disease Details').set(filteredDiseases);
        }

        // Save pet details if any
        if (hasPetDetails) {
          await ref.child('Pet Details').set({
            'Animal Type': petAnimalType,
            'Breed': petBreed,
            'Name': petName,
            'Age': {'Months': petAgeMonth, 'Years': petAgeYear},
            'Gender': petGender,
            'Weight': {'Kg': petWeightKg, 'Gm': petWeightGm},
          });
        }

        // Navigate to home screen after saving details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } catch (e) {
        print('Error saving details: $e');
        // Handle error gracefully, e.g., show a snackbar or retry option
      }
    }
  }
}
