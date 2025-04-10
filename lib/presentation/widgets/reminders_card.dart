import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class RemindersCard extends StatefulWidget {
  @override
  _RemindersCardState createState() => _RemindersCardState();
}

class _RemindersCardState extends State<RemindersCard> {
  List<Map<String, dynamic>> _reminders = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(android: androidInitSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString('reminders');
    if (remindersJson != null) {
      setState(() {
        _reminders = List<Map<String, dynamic>>.from(json.decode(remindersJson));
      });
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminders', json.encode(_reminders));
  }

  void _addReminder(String title, TimeOfDay time) {
    final newReminder = {'title': title, 'hour': time.hour, 'minute': time.minute};
    setState(() {
      _reminders.add(newReminder);
    });
    _scheduleNotification(newReminder);
    _saveReminders();
  }

  Future<void> _scheduleNotification(Map<String, dynamic> reminder) async {
    final now = TimeOfDay.now();
    final scheduledTime = TimeOfDay(hour: reminder['hour'], minute: reminder['minute']);

    final androidDetails = AndroidNotificationDetails(
      'reminder_channel', 'Reminders',
      importance: Importance.high, priority: Priority.high,
    );
    final platformDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.zonedSchedule(
      reminder.hashCode,
      'Reminder',
      reminder['title'],
      _nextInstanceOfTime(reminder['hour'], reminder['minute']),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  void _showAddReminderDialog() {
    TextEditingController reminderController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Reminder"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reminderController,
              decoration: InputDecoration(labelText: "Reminder Title"),
            ),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (pickedTime != null) {
                  selectedTime = pickedTime;
                }
              },
              child: Text("Pick Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (reminderController.text.isNotEmpty) {
                _addReminder(reminderController.text, selectedTime);
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _showAddReminderDialog,
                child: Text("+"),
              ),
              ..._reminders.map((reminder) => ListTile(
                title: Text(reminder['title']),
                subtitle: Text(
                    "${reminder['hour'].toString().padLeft(2, '0')}:${reminder['minute'].toString().padLeft(2, '0')}"),
              )),

            ],
          ),
        ),
      ),
    );
  }
}
