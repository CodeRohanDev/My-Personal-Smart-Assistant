// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:my_personal_smart_assistant/views/Profile_page.dart';
import 'package:my_personal_smart_assistant/views/cook_page.dart';
import 'package:my_personal_smart_assistant/views/dog_care_page.dart';
import 'package:my_personal_smart_assistant/views/health_page.dart';
import 'package:my_personal_smart_assistant/views/home_screen.dart';
import 'package:my_personal_smart_assistant/views/login_screen.dart';
import 'package:my_personal_smart_assistant/views/splash_screen.dart';
import 'package:my_personal_smart_assistant/views/tutor_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    HealthScreen(),
    CookScreen(),
    ChatScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _currentIndex,
        showElevation: true,
        onItemSelected: (index) => setState(() => _currentIndex = index),
        items: [
          FlashyTabBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            title: Text('Home'),
          ),
          FlashyTabBarItem(
            icon: Icon(
              Icons.health_and_safety_sharp,
              size: 30,
            ),
            title: Text('Health'),
          ),
          FlashyTabBarItem(
            icon: Icon(
              Icons.restaurant,
              size: 30,
            ),
            title: Text('Cook'),
          ),
          FlashyTabBarItem(
            icon: Icon(
              Icons.school,
              size: 30,
            ),
            title: Text('Tutor'),
          ),
          FlashyTabBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            title: Text('Profile'),
          ),
        ],
      ),
    );
  }
}
