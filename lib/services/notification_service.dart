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

    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final granted = await androidImplementation?.areNotificationsEnabled();
      print('Android notification permission status: $granted');
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
      final dueDateAlertsEnabled = prefs.getBool('dueDateAlerts') ?? true;
      final reminderHours = prefs.getInt('reminderTime') ?? 1;

      if (!isEnabled && !dueDateAlertsEnabled) {
        print('All notifications are disabled');
        return;
      }

      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        print('Notification permissions not granted');
        return;
      }

      final now = DateTime.now();
      print('Scheduling notifications for task: $title');
      print('Current time: ${now.toString()}');
      print('Due date: ${dueDate.toString()}');

      // Schedule reminder notification
      if (isEnabled) {
        final reminderDate = dueDate.subtract(Duration(hours: reminderHours));
        if (reminderDate.isAfter(now)) {
          await _scheduleNotification(
            id: '${taskId}_reminder'.hashCode,
            title: 'Task Reminder',
            body:
                'Task "$title" is due in $reminderHours ${reminderHours == 1 ? 'hour' : 'hours'}',
            description: description,
            scheduledDate: reminderDate,
            payload: {
              'taskId': taskId,
              'title': title,
              'dueDate': DateTimeUtils.formatDateTime(dueDate),
              'type': 'reminder',
            },
          );
          print(
              'Reminder notification scheduled for: ${reminderDate.toString()}');
        }
      }

      // Schedule due date notification
      if (dueDateAlertsEnabled) {
        if (dueDate.isAfter(now)) {
          await _scheduleNotification(
            id: '${taskId}_due'.hashCode,
            title: 'Task Due',
            body: 'Task "$title" is due now',
            description: description,
            scheduledDate: dueDate,
            payload: {
              'taskId': taskId,
              'title': title,
              'dueDate': DateTimeUtils.formatDateTime(dueDate),
              'type': 'due_date',
            },
          );
          print('Due date notification scheduled for: ${dueDate.toString()}');
        }
      }
    } catch (e, stackTrace) {
      print('Error scheduling notifications: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String description,
    required DateTime scheduledDate,
    required Map<String, dynamic> payload,
  }) async {
    final location = tz.local;
    final scheduledTz = tz.TZDateTime.from(scheduledDate, location);

    print('Scheduling notification:');
    print('ID: $id');
    print('Title: $title');
    print('Scheduled for: ${scheduledDate.toString()}');
    print('Timezone: ${location.name}');

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTz,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _taskChannelId,
          _taskChannelName,
          channelDescription: _taskChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            description,
            contentTitle: title,
            summaryText: 'Due: ${DateTimeUtils.formatDateTime(scheduledDate)}',
          ),
          fullScreenIntent: true,
          category: AndroidNotificationCategory.reminder,
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
      matchDateTimeComponents: DateTimeComponents.time,
      payload: json.encode(payload),
    );
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
    await _localNotifications.cancel('${taskId}_reminder'.hashCode);
    await _localNotifications.cancel('${taskId}_due'.hashCode);
    print('Cancelled notifications for task: $taskId');
  }

  Future<void> _setupNotificationTapHandling() async {
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
        // Navigate to task detail screen using the taskId from payload
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

    print('Updated notification settings:');
    print('Task reminders enabled: $taskReminders');
    print('Due date alerts enabled: $dueDateAlerts');
    print('Reminder time: $reminderTime hours');

    // Cancel all notifications if all reminders are disabled
    if (!taskReminders && !dueDateAlerts) {
      await _localNotifications.cancelAll();
      print('Cancelled all notifications due to settings update');
    }
  }

  Future<bool> checkPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final areNotificationsEnabled =
            await androidImplementation?.areNotificationsEnabled();
        print('Android notifications enabled: $areNotificationsEnabled');
        return areNotificationsEnabled ?? false;
      } else if (Platform.isIOS) {
        final iosImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImplementation?.requestPermissions(
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

  // Debug method for testing
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

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('Cancelled all notifications');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
