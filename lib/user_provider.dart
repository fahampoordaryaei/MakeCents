import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dataconnect_generated/generated.dart';
import 'functions.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String? institution;
  final String? course;
  final String? otherSchool;
  final String? otherCourse;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.institution,
    this.course,
    this.otherSchool,
    this.otherCourse,
  });

  String get fullName => '$firstName $lastName';

  String get displayInstitution {
    if (institution == null) return 'Not set';
    if (institution == 'Other' &&
        otherSchool != null &&
        otherSchool!.isNotEmpty) {
      return otherSchool!;
    }
    return institution!;
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
      final result = await connector.getUserProfile(userId: user.uid).execute();

      _profile = null;
      if (result.data.users.isNotEmpty) {
        final u = result.data.users.first;
        _profile = UserProfile(
          firstName: u.firstName,
          lastName: u.lastName,
          email: user.email ?? '',
          institution: u.institution?.name,
          course: u.course?.name,
          otherSchool: u.otherSchool,
          otherCourse: u.otherCourse,
        );
        if (u.currency != null) {
          setGlobalCurrency(sign: u.currency!.sign, id: u.currency!.id);
        }
      }
    } catch (e) {
      debugPrint('user_provider: loadProfile failed: $e');
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
