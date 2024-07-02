// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class DogCarePage extends StatefulWidget {
  const DogCarePage({super.key});

  @override
  State<DogCarePage> createState() => _DogCarePageState();
}

class _DogCarePageState extends State<DogCarePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("This is Dog Care Page"),
      ),
    );
  }
}
