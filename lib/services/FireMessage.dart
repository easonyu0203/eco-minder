import 'package:firebase_messaging/firebase_messaging.dart';

class FireMessageService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> checkAndRequestNotificationPermissions() async {
    NotificationSettings settings =
        await _firebaseMessaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      String? token = await getDeviceToken();
      print(token);
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('User has denied the notification permissions.');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User has granted the notification permissions.');
      String? token = await getDeviceToken();
      print(token);
    }

    _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, sound: true, badge: true);
  }

  Future<String?> getDeviceToken() async {
    String? deviceToken = await _firebaseMessaging.getToken();
    return deviceToken;
  }
}
