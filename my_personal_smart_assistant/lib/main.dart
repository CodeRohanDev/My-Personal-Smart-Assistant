import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_personal_smart_assistant/views/home/add_details.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'views/auth/login_page.dart';
import 'views/home/home_page.dart';
import 'views/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(
        navigateToDetails: () {
          Navigator.pushReplacementNamed(context, '/add_details');
        },
      ),
      child: MaterialApp(
        title: 'My App',
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/add_details': (context) =>
              AddDetailsPage(), // Add the route for details entry page
        },
      ),
    );
  }
}
