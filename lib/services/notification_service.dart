// lib/services/notification_service.dart
import 'dart:io' show Platform;
import 'dart:convert';

import 'package:dd_smart_todo_app/utils/date_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _taskChannelId = 'task_notifications';
  static const String _taskChannelName = 'Task Notifications';
  static const String _taskChannelDescription =
      'Notifications for tasks and reminders';

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Request notification permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle notification taps
    await _setupNotificationTapHandling();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showLocalNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: json.encode(message.data),
      );
    }
  }

  Future<void> _requestPermissions() async {
    // Request FCM permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Request local notification permissions for iOS
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    // Request precise alarms permission for Android
    if (Platform.isAndroid) {
      final androidImpl =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the notification channel for Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _taskChannelId,
              _taskChannelName,
              description: _taskChannelDescription,
              importance: Importance.high,
              enableVibration: true,
              enableLights: true,
            ),
          );
    }
  }

  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('taskReminders') ?? true;
      final reminderHours = prefs.getInt('reminderTime') ?? 1;

      if (!isEnabled) {
        print('Task reminders are disabled');
        return;
      }

      final scheduledDate = dueDate.subtract(Duration(hours: reminderHours));
      final now = DateTime.now();

      // Don't schedule if the time has already passed
      if (scheduledDate.isBefore(now)) {
        print('Skipping notification for past due task: $title');
        print('Scheduled time: ${DateTimeUtils.formatDateTime(scheduledDate)}');
        print('Current time: ${DateTimeUtils.formatDateTime(now)}');
        return;
      }

      // Convert to local timezone
      final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);

      final payload = {
        'taskId': taskId,
        'title': title,
        'dueDate': DateTimeUtils.formatDateTime(dueDate),
        'type': 'task_reminder',
      };

      print('Scheduling notification for task: $title');
      print('Due date: ${DateTimeUtils.formatDateTime(dueDate)}');
      print('Scheduled for: ${DateTimeUtils.formatDateTime(scheduledDate)}');

      await _localNotifications.zonedSchedule(
        taskId.hashCode,
        'Task Reminder',
        'Task "$title" is due in $reminderHours ${reminderHours == 1 ? 'hour' : 'hours'}',
        scheduledTz,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _taskChannelId,
            _taskChannelName,
            channelDescription: _taskChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'Task Reminder',
            styleInformation: BigTextStyleInformation(
              description,
              contentTitle: title,
              summaryText: 'Due: ${DateTimeUtils.formatDateTime(dueDate)}',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: 1,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: json.encode(payload),
      );

      print('Notification scheduled successfully');
    } catch (e) {
      print('Error scheduling notification: $e');
      print('Task ID: $taskId');
      print('Title: $title');
      print('Due date: ${DateTimeUtils.formatDateTime(dueDate)}');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _taskChannelId,
          _taskChannelName,
          channelDescription: _taskChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> cancelTaskReminder(String taskId) async {
    await _localNotifications.cancel(taskId.hashCode);
  }

  Future<void> _setupNotificationTapHandling() async {
    // Get any initial notification that launched the app
    final initialNotification =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (initialNotification?.didNotificationLaunchApp ?? false) {
      final response = initialNotification?.notificationResponse;
      if (response != null) {
        _handleNotificationTap(response);
      }
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    _handleNotificationTap(response);
  }

  void _handleNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        print('Notification payload data: $data');
        // TODO: Implement navigation based on payload
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  Future<void> updateNotificationSettings({
    required bool taskReminders,
    required bool dueDateAlerts,
    required int reminderTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('taskReminders', taskReminders);
    await prefs.setBool('dueDateAlerts', dueDateAlerts);
    await prefs.setInt('reminderTime', reminderTime);

    // Cancel all notifications if reminders are disabled
    if (!taskReminders) {
      await _localNotifications.cancelAll();
    }
  }

  // Debug method to show an immediate test notification
  Future<void> showDebugNotification({
    required String title,
    required String body,
  }) async {
    final payload = {
      'type': 'debug',
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _showLocalNotification(
      title: title,
      body: body,
      payload: json.encode(payload),
    );
    print('Showing debug notification: $title');
  }

  // Method to check notification permissions
  Future<bool> checkPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidImpl =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted =
            await androidImpl?.requestNotificationsPermission() ?? false;
        print('Android notification permissions granted: $granted');
        return granted;
      } else if (Platform.isIOS) {
        final iosImpl =
            _localNotifications.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
        print('iOS notification permissions granted: $granted');
        return granted;
      }
      return false;
    } catch (e) {
      print('Error checking notification permissions: $e');
      return false;
    }
  }

  // Method to cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
