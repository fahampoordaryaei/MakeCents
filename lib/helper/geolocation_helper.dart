import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class ProfileCountryResult {
  const ProfileCountryResult({
    required this.isoCountryCode,
    required this.displayName,
  });

  final String isoCountryCode;
  final String displayName;
}

Future<Position> _positionForCountry() async {
  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 20),
      ),
    );
  } on TimeoutException {
    throw StateError('Location timed out. Please try again.');
  } catch (e) {
    throw StateError('Could not read location: $e');
  }
}

Future<ProfileCountryResult> getCountryFromLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw StateError('Location services are off. Turn them on and try again.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    throw StateError(
      'Location access is blocked. Enable it for this app in Settings.',
    );
  }
  if (permission != LocationPermission.whileInUse &&
      permission != LocationPermission.always) {
    throw StateError('Location permission denied.');
  }

  final position = await _positionForCountry();

  final placemarks = await placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );
  if (placemarks.isEmpty) {
    throw StateError('Could not detect country.');
  }

  final p = placemarks.first;
  final iso = p.isoCountryCode?.trim();
  if (iso == null || iso.isEmpty) {
    throw StateError('Could not detect country.');
  }

  final countryTrimmed = p.country?.trim();
  final name = (countryTrimmed != null && countryTrimmed.isNotEmpty)
      ? countryTrimmed
      : iso;

  return ProfileCountryResult(
    isoCountryCode: iso.toUpperCase(),
    displayName: name,
  );
}
