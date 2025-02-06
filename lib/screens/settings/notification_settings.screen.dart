import 'package:flutter/material.dart';

import 'package:dd_smart_todo_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _taskReminders = true;
  bool _dueDateAlerts = true;
  int _reminderTime = 1;
  bool _isLoading = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await NotificationService().checkPermissions();
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
      });

      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enable notifications in system settings to receive task reminders',
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _taskReminders = prefs.getBool('taskReminders') ?? true;
      _dueDateAlerts = prefs.getBool('dueDateAlerts') ?? true;
      _reminderTime = prefs.getInt('reminderTime') ?? 1;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await NotificationService().updateNotificationSettings(
        taskReminders: _taskReminders,
        dueDateAlerts: _dueDateAlerts,
        reminderTime: _reminderTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            title: 'Task Reminders',
            children: [
              SwitchListTile(
                title: const Text('Enable Task Reminders'),
                subtitle: const Text('Get notified about upcoming tasks'),
                value: _taskReminders,
                onChanged: (value) => setState(() => _taskReminders = value),
              ),
              if (_taskReminders) ...[
                const Divider(),
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: const Text('When to send task reminders'),
                  trailing: DropdownButton<int>(
                    value: _reminderTime,
                    items: [1, 2, 3, 6, 12, 24].map((hours) {
                      return DropdownMenuItem(
                        value: hours,
                        child: Text('$hours ${hours == 1 ? 'hour' : 'hours'}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _reminderTime = value);
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            title: 'Due Date Alerts',
            children: [
              SwitchListTile(
                title: const Text('Due Date Alerts'),
                subtitle: const Text('Get notified when tasks are due'),
                value: _dueDateAlerts,
                onChanged: (value) => setState(() => _dueDateAlerts = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveSettings,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Settings'),
          ),
          SizedBox(
            height: 20,
          ),

          if (_hasPermission) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                try {
                  final now = DateTime.now();
                  // Schedule for 1 minute from now
                  final scheduledTime = now.add(const Duration(minutes: 1));

                  print('Scheduling test notification:');
                  print('Current time: ${now.toString()}');
                  print('Scheduled for: ${scheduledTime.toString()}');

                  await NotificationService().scheduleTaskReminder(
                    taskId: 'test_task_${now.millisecondsSinceEpoch}',
                    title: 'Test Scheduled Task',
                    description: 'This is a test scheduled notification',
                    dueDate:
                        scheduledTime, 
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notification scheduled'),
                            Text('Current time: ${now.toString()}'),
                            Text('Scheduled for: ${scheduledTime.toString()}'),
                          ],
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error scheduling test notification: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error scheduling notification: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              child: const Text('Schedule Test Notification (1 min)'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
