import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:happiness_hub/models/task.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // A static instance of the plugin is used to ensure it's a singleton.
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initializes the notification service and requests permissions.
  // This should be called once when the app starts.
  Future<void> init() async {
    // Initialization settings for Android.
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialization settings for iOS.
    // This requests permissions for alerts, badges, and sounds.
    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    // Initialize the plugin with the settings.
    await _notificationsPlugin.initialize(initializationSettings);

    // Initialize timezone data, which is crucial for scheduling notifications correctly.
    tz.initializeTimeZones();
  }

  // Schedules a notification for a given task.
  Future<void> scheduleNotification(Task task) async {
    // Define the details of the notification for Android.
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'schedule_channel', // A unique channel ID
      'Task Reminders',   // A user-visible channel name
      channelDescription: 'Channel for task and event reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'), // Assumes you have a sound file in android/app/src/main/res/raw/
    );

    // Define the details for iOS.
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    // Ensure the task's date/time is in the future before scheduling.
    if (task.dateTime.isAfter(DateTime.now())) {
      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode, // Use a hash of the task's unique ID as the notification ID.
        task.title,       // The title of the notification (the task's title).
        'Reminder for your task at ${task.dateTime.hour.toString().padLeft(2, '0')}:${task.dateTime.minute.toString().padLeft(2, '0')}', // The body of the notification.
        tz.TZDateTime.from(task.dateTime, tz.local), // The scheduled time in the local timezone.
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Cancels a previously scheduled notification.
  // This should be called when a task is deleted.
  Future<void> cancelNotification(String taskId) async {
    // Use the same hash code to identify and cancel the correct notification.
    await _notificationsPlugin.cancel(taskId.hashCode);
  }
}

