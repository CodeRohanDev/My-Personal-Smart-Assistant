import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  User? get user => _user;
  VoidCallback? navigateToDetails; // Callback for navigation

  AuthProvider({required this.navigateToDetails}) {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
    _authService.user.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
    await _checkNewUser();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null; // Ensure _user is set to null on sign out
    notifyListeners();
  }

  Future<void> _checkNewUser() async {
    // Check if additional details are needed for new users
    if (_user != null) {
      // Example: Check if the user's display name is set
      if (_user!.displayName == null || _user!.displayName!.isEmpty) {
        // Navigate using callback function
        navigateToDetails?.call();
      }
    }
  }
}
