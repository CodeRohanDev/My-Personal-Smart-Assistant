import 'package:flutter/material.dart';
import 'views/auth/login_page.dart';
import 'views/home/home_page.dart';

Map<String, WidgetBuilder> routes = {
  '/login': (context) => LoginPage(),
  '/home': (context) => HomePage(),
};
