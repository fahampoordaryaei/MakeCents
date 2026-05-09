import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:makecents/dataconnect_generated/generated.dart';
import 'package:makecents/page/scholarship_application_page.dart';

typedef UploadResult = ({String path, String filename});

Future<UploadResult> uploadAttachment(File file, {String? displayName}) async {
  final uuid = const Uuid().v4();
  final raw = displayName ?? file.path.replaceAll(r'\', '/').split('/').last;
  var filename = raw.replaceAll(RegExp(r'[/\\]'), '_').trim();
  if (filename.isEmpty) filename = 'attachment';

  final path = 'Documents/$uuid/$filename';
  await FirebaseStorage.instance.ref(path).putFile(file);
  return (path: path, filename: filename);
}

Future<void> sendUserEmailVerification(User user) async {
  final projectId = Firebase.app().options.projectId;
  final continueUrl = Uri.https('$projectId.firebaseapp.com', '/').toString();
  await user.sendEmailVerification(
    ActionCodeSettings(url: continueUrl, handleCodeInApp: false),
  );
}

Future<List<ListGlobalScholarshipsScholarships>> fetchScholarships(
  ExampleConnector connector, {
  required int? countryId,
}) async {
  if (countryId != null) {
    final rows =
        (await connector
                .getContinentsForCountry(countryId: countryId)
                .execute())
            .data
            .countryContinents;
    if (rows.isNotEmpty) {
      final r = await connector
          .listScholarshipsForUser(
            countryId: countryId,
            continentId: rows.first.continent.id,
          )
          .execute();
      return [
        for (final s in r.data.scholarships)
          ListGlobalScholarshipsScholarships.fromJson(s.toJson()),
      ];
    }
  }

  final r = await connector.listGlobalScholarships().execute();
  return r.data.scholarships;
}

(String text, Color color) scholarshipRegion(
  ListGlobalScholarshipsScholarships s,
) {
  final c = s.country;
  if (c != null) {
    final t = c.name.trim();
    if (t.isNotEmpty) return (t.toUpperCase(), const Color(0xFF00796B));
  }
  final k = s.continent;
  if (k != null) {
    final t = k.name.trim();
    if (t.isNotEmpty) return (t.toUpperCase(), const Color(0xFF7B1FA2));
  }
  return ('GLOBAL', const Color(0xFF1565C0));
}

Future<void> openScholarshipApply(
  BuildContext context, {
  String? scholarshipId,
  required String title,
  required String provider,
  required double amount,
  required String currency,
  required String description,
  required Color brandColor,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ScholarshipApplicationPage(
        scholarshipId: scholarshipId,
        title: title,
        provider: provider,
        amount: amount,
        currency: currency,
        description: description,
        brandColor: brandColor,
      ),
    ),
  );
}
