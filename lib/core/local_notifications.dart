import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationManage {
  static initLocalNotification() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<bool?> checkNotificationEnabled() async {
    var androidPlugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    bool? notificationEnabled = await androidPlugin?.areNotificationsEnabled();
    return notificationEnabled;
  }
}
