import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dataconnect_generated/generated.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String? school;
  final String? course;
  final String? otherSchool;
  final String? otherCourse;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.school,
    this.course,
    this.otherSchool,
    this.otherCourse,
  });

  String get fullName => '$firstName $lastName';

  String get displaySchool {
    if (school == null) return 'Not set';
    if (school == 'Other' && otherSchool != null && otherSchool!.isNotEmpty) {
      return otherSchool!;
    }
    return school!;
  }

  String get displayCourse {
    if (course == null) return 'Not set';
    if (course == 'Other' && otherCourse != null && otherCourse!.isNotEmpty) {
      return otherCourse!;
    }
    return course!;
  }
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
          otherSchool: u.otherSchool,
          otherCourse: u.otherCourse,
        );
      } else {
        _profile = null;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _profile = null;
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
