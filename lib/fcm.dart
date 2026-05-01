import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

const _channel = AndroidNotificationChannel(
  'makecents_fcm',
  'MakeCents alerts',
  importance: Importance.high,
);

final _local = FlutterLocalNotificationsPlugin();
var _localReady = false;

String? _storedUid;
String? _storedToken;

Future<void> _saveFcmToken(String uid, String token) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'fcmTokens': FieldValue.arrayUnion([token]),
  }, SetOptions(merge: true));
}

Future<void> _deleteFcmToken(String uid, String token) async {
  final ref = FirebaseFirestore.instance.collection('users').doc(uid);
  final snap = await ref.get();
  if (!snap.exists) return;
  await ref.update({
    'fcmTokens': FieldValue.arrayRemove([token]),
  });
}

Future<void> _syncTokenToFirestore(String? token) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || token == null || token.isEmpty) return;
  try {
    await _saveFcmToken(user.uid, token);
    _storedUid = user.uid;
    _storedToken = token;
  } on FirebaseException catch (_) {
  } catch (_) {}
}

Future<void> _removeTokenOnSignOut() async {
  final uid = _storedUid;
  final token = _storedToken;
  if (uid == null || token == null) return;
  try {
    await _deleteFcmToken(uid, token);
  } on FirebaseException catch (_) {
  } catch (_) {}
  _storedUid = null;
  _storedToken = null;
}

void _attachAuthAndTokenFirestore(
  FirebaseMessaging messaging, {
  String? webVapidKey,
}) {
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user == null) {
      await _removeTokenOnSignOut();
      return;
    }
    final t = webVapidKey != null
        ? await messaging.getToken(vapidKey: webVapidKey)
        : await messaging.getToken();
    await _syncTokenToFirestore(t);
  });

  FirebaseMessaging.instance.onTokenRefresh.listen(_syncTokenToFirestore);
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> initializeFirebaseMessaging() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) return;

  const vapidKey = String.fromEnvironment('FIREBASE_VAPID_KEY');
  if (kIsWeb && vapidKey.isEmpty) return;

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  _attachAuthAndTokenFirestore(
    messaging,
    webVapidKey: kIsWeb ? vapidKey : null,
  );

  final token = kIsWeb
      ? await messaging.getToken(vapidKey: vapidKey)
      : await messaging.getToken();
  await _syncTokenToFirestore(token);

  if (defaultTargetPlatform == TargetPlatform.android) {
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_channel);
    await android?.requestNotificationsPermission();
    _localReady = true;
  }

  FirebaseMessaging.onMessage.listen((message) async {
    final n = message.notification;
    if (n == null || !_localReady) return;
    await _showForegroundTray(title: n.title, body: n.body);
  });
}

Future<void> _showForegroundTray({
  required String? title,
  required String? body,
}) async {
  await _local.show(
    DateTime.now().millisecondsSinceEpoch % 100000,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      ),
    ),
  );
}
