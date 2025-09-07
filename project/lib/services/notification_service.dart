import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:happiness_hub/models/task.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  
  Future<void> init() async {
    
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    
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

    
    await _notificationsPlugin.initialize(initializationSettings);

    
    tz.initializeTimeZones();
  }

  
  Future<void> scheduleNotification(Task task) async {
    
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'schedule_channel', 
      'Task Reminders',   
      channelDescription: 'Channel for task and event reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'), // Assumes you have a sound file in android/app/src/main/res/raw/
    );

    
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

    
    if (task.dateTime.isAfter(DateTime.now())) {
      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode, 
        task.title,       
        'Reminder for your task at ${task.dateTime.hour.toString().padLeft(2, '0')}:${task.dateTime.minute.toString().padLeft(2, '0')}', // The body of the notification.
        tz.TZDateTime.from(task.dateTime, tz.local), 
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  
  Future<void> cancelNotification(String taskId) async {
    
    await _notificationsPlugin.cancel(taskId.hashCode);
  }
}

