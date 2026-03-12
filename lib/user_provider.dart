import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dataconnect_generated/generated.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String? school;
  final String? course;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.school,
    this.course,
  });
}

class UserProvider with ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _profile = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final connector = ExampleConnector.instance;
      final result = await connector
          .getUserProfile(username: user.uid)
          .execute();

      if (result.data.users.isNotEmpty) {
        final u = result.data.users.first;
        _profile = UserProfile(
          firstName: u.firstName,
          lastName: u.lastName,
          email: user.email ?? '',
          school: u.school?.name,
          course: u.course?.name,
        );
      } else {
        // Fallback to Firebase Auth display name if DB record missing
        final names = (user.displayName ?? '').split(' ');
        _profile = UserProfile(
          firstName: names.isNotEmpty ? names[0] : 'User',
          lastName: names.length > 1 ? names.sublist(1).join(' ') : '',
          email: user.email ?? '',
        );
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
