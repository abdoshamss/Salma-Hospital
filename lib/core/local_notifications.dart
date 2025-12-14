import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationManage {
  static Future<bool?> checkNotificationEnabled() async {
    var androidPlugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool? notificationEnabled = await androidPlugin?.areNotificationsEnabled();
    return notificationEnabled;
  }
}
