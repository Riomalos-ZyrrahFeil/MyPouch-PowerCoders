import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'database_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    String timeZoneName = 'UTC'; 
    try {
      final dynamic result = await FlutterTimezone.getLocalTimezone();
      timeZoneName = result.toString();
      if (timeZoneName.contains('TimezoneInfo')) {
        timeZoneName = timeZoneName.replaceAll('TimezoneInfo(', '').replaceAll(')', '');
        if (timeZoneName.contains(',')) {
        }
      }
    } catch (e) {
      debugPrint("Timezone Error: $e");
    }

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("✅ Timezone set to: $timeZoneName");
    } catch (e) {
      debugPrint("⚠️ Could not set location '$timeZoneName'. Defaulting to UTC.");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    var status = await Permission.scheduleExactAlarm.status;
    if (status.isDenied) {
       debugPrint("Requesting Exact Alarm permission...");
       status = await Permission.scheduleExactAlarm.request();
    }
    
    if (status.isPermanentlyDenied) {
      debugPrint("Exact Alarm permission permanently denied. Open settings.");
      await openAppSettings(); 
    }

    return true;
  }

  // Schedule Daily Reminder
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Reminds you to save money every day',
            importance: Importance.max,
            priority: Priority.high,
            color: Color(0xFF015940),
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, 
      );
      debugPrint("✅ Notification Scheduled for $scheduledDate");
    } catch (e) {
      debugPrint("❌ Error scheduling: $e");
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
  
  Future<void> showInstantNotification() async {
    const title = 'Test Notification';
    const body = 'This is a test to confirm notifications are working!';

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );

    await DatabaseHelper().addNotification(title, body);
  }
}