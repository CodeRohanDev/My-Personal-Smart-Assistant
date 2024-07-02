import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:my_personal_smart_assistant/views/Profile_page.dart';
import 'package:my_personal_smart_assistant/views/cook_page.dart';
import 'package:my_personal_smart_assistant/views/dog_care_page.dart';
import 'package:my_personal_smart_assistant/views/home_screen.dart';
import 'package:my_personal_smart_assistant/views/login_screen.dart';
import 'package:my_personal_smart_assistant/views/splash_screen.dart';
import 'package:my_personal_smart_assistant/views/tutor_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
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
      initialRoute: '/', // Set your default route if needed
      routes: {
        '/': (context) => SplashScreen(), // Example default route
        '/login': (context) => LoginScreen(), // Route for login screen
        // Add more routes as needed
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0; // Start with Home page as default

  // Define the pages with their corresponding widgets
  final List<Widget> _pages = [
    HomeScreen(),
    DogCarePage(),
    CookPage(),
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
              Icons.pets,
              size: 30,
            ),
            title: Text('Dog Care'),
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
