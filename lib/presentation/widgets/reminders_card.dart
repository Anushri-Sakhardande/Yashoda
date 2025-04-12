import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class RemindersCard extends StatefulWidget {
  const RemindersCard({super.key});

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

  Future<void> requestPermissions() async {
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    await requestPermissions();

    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(android: androidInitSettings);

    await _notificationsPlugin.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      importance: Importance.max,
      description: 'This channel is used for reminder notifications',
    );

    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
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
    final newReminder = {
      'title': title,
      'hour': time.hour,
      'minute': time.minute,
    };
    setState(() {
      _reminders.add(newReminder);
    });
    _scheduleNotification(newReminder);
    _saveReminders();
  }

  void _deleteReminder(Map<String, dynamic> reminder) async {
    setState(() {
      _reminders.remove(reminder);
    });
    await _notificationsPlugin.cancel(reminder.hashCode);
    _saveReminders();
  }

  Future<void> _scheduleNotification(Map<String, dynamic> reminder) async {
    final tz.TZDateTime scheduledTime = _nextInstanceOfTime(reminder['hour'], reminder['minute']);

    await _notificationsPlugin.zonedSchedule(
      reminder.hashCode,
      'Reminder',
      reminder['title'],
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
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
        padding: EdgeInsets.all(0),
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
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteReminder(reminder),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
