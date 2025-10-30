// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_local_variable, depend_on_referenced_packages, unnecessary_null_in_if_null_operators

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'home_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  TasksPageState createState() => TasksPageState();
}

class TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> tasks = [];
  late AnimationController _holoController;
  int _selectedBottomIndex = 2;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadTasksFromFirestore();

    _holoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _holoController.dispose();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    tzdata.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzScheduled =
        tz.TZDateTime.from(scheduledDate, tz.local);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tasks_channel',
          'Tareas',
          channelDescription: 'Notificaciones de tareas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> _loadTasksFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('tasks')
        .get();
    setState(() {
      tasks = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'title': doc.data()['title'] ?? '',
                'description': doc.data()['description'] ?? '',
                'subject': doc.data()['subject'] ?? '',
                'color': doc.data()['color'] ?? Colors.purple.value,
                'icon': doc.data()['icon'] ?? Icons.check.codePoint,
                'scheduledDate': doc.data()['scheduledDate'] ?? null,
              })
          .toList();
    });
  }

  Future<void> _addTask({
    required String title,
    required String description,
    required String subject,
    required Color color,
    required IconData icon,
    required DateTime dateTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('tasks')
        .add({
      'title': title,
      'description': description,
      'subject': subject,
      'color': color.value,
      'icon': icon.codePoint,
      'scheduledDate': dateTime.toIso8601String(),
    });

    setState(() {
      tasks.add({
        'id': docRef.id,
        'title': title,
        'description': description,
        'subject': subject,
        'color': color.value,
        'icon': icon.codePoint,
        'scheduledDate': dateTime.toIso8601String(),
      });
    });

    _scheduleNotification(
        id: tasks.length,
        title: 'Tarea: $title',
        body: '¡No olvides completar tu tarea!',
        scheduledDate: dateTime);
  }

  Future<void> _removeTask(Map<String, dynamic> task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('tasks')
        .doc(task['id'])
        .delete();
    _cancelNotification(tasks.indexOf(task) + 1);
    setState(() {
      tasks.remove(task);
    });
  }

  void _onMenuTap(int index) {
    setState(() => _selectedBottomIndex = index);
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(onThemeChanged: (bool value) {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.purple,
      Colors.pink,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.pink.shade100,
      Colors.purple.shade100,
      Colors.orange.shade200,
      Colors.blue.shade200,
      Colors.green.shade200,
    ];

    final List<IconData> icons = [
      Icons.check,
      Icons.star,
      Icons.alarm,
      Icons.book,
      Icons.work,
      Icons.school,
      Icons.favorite,
      Icons.event,
      Icons.lightbulb,
      Icons.music_note,
    ];

    final List<String> subjects = [
      'Matemáticas',
      'Lengua',
      'Historia',
      'Ciencias',
      'Inglés',
      'Arte',
      'Música',
      'Educación Física',
      'Química',
      'Física',
    ];

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondoencuesta2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                // Botón regresar holográfico
                Positioned(
                  top: 16,
                  left: 16,
                  child: AnimatedBuilder(
                    animation: _holoController,
                    builder: (context, child) {
                      final lerpColor = Color.lerp(
                          Colors.pink.shade200,
                          Colors.purple.shade200,
                          _holoController.value)!;
                      return CircleAvatar(
                        radius: 28,
                        backgroundColor: lerpColor,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      );
                    },
                  ),
                ),
                // Botón añadir tarea holográfico
                Positioned(
                  top: 16,
                  right: 16,
                  child: AnimatedBuilder(
                    animation: _holoController,
                    builder: (context, child) {
                      final lerpColor = Color.lerp(
                          Colors.purple.shade200,
                          Colors.pink.shade200,
                          _holoController.value)!;
                      return CircleAvatar(
                        radius: 28,
                        backgroundColor: lerpColor,
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () => _showAddTaskDialog(icons, colors, subjects),
                        ),
                      );
                    },
                  ),
                ),
                // Título TAREAS
                Center(
                  child: Text(
                    'TAREAS',
                    style: const TextStyle(
                        fontFamily: 'LuckiestGuy-Regular',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                // Lista de tareas
                Positioned(
                  top: 120,
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final color = Color(task['color']);
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ListTile(
                          leading: Icon(
                            IconData(task['icon'], fontFamily: 'MaterialIcons'),
                            color: color,
                          ),
                          title: Text(
                            task['title'],
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${task['description']} - ${task['subject']}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          trailing: IconButton(
                              icon: const Icon(Icons.check, color: Colors.white),
                              onPressed: () => _removeTask(task)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _holoController,
        builder: (context, child) {
          final lerpColor1 = Color.lerp(
              Colors.pink.shade200, Colors.purple.shade200, _holoController.value)!;
          final lerpColor2 = Color.lerp(
              Colors.purple.shade200, Colors.pink.shade200, _holoController.value)!;
          return Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMenuItem(Icons.home, 0, lerpColor1),
                _buildMenuItem(Icons.chat, 1, lerpColor1),
                Transform.scale(
                  scale: 1.1,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [lerpColor1, lerpColor2]),
                      boxShadow: [
                        BoxShadow(
                          color: lerpColor1.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.list_alt, color: Colors.white, size: 36),
                  ),
                ),
                _buildMenuItem(Icons.favorite, 3, lerpColor1),
                _buildMenuItem(Icons.settings, 4, lerpColor1),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, int index, Color color) {
    final isSelected = _selectedBottomIndex == index;
    return GestureDetector(
      onTap: () => _onMenuTap(index),
      child: Icon(icon,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: isSelected ? 30 : 26),
    );
  }

  void _showAddTaskDialog(
      List<IconData> icons, List<Color> colors, List<String> subjects) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedSubject = subjects[0];
    Color selectedColor = colors[0];
    IconData selectedIcon = icons[0];
    DateTime selectedDate = DateTime.now().add(const Duration(minutes: 1));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Agregar Tarea',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      labelText: 'Título', labelStyle: TextStyle(color: Colors.black54)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Descripción', labelStyle: TextStyle(color: Colors.black54)),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: selectedSubject,
                  items: subjects.map((sub) {
                    return DropdownMenuItem(value: sub, child: Text(sub));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedSubject = val!),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colors
                      .map((c) => GestureDetector(
                            onTap: () => setState(() => selectedColor = c),
                            child: CircleAvatar(
                              backgroundColor: c,
                              radius: selectedColor == c ? 20 : 16,
                              child: selectedColor == c
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: icons
                      .map((i) => GestureDetector(
                            onTap: () => setState(() => selectedIcon = i),
                            child: Icon(i,
                                color: selectedIcon == i ? selectedColor : Colors.grey[600],
                                size: 32),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.black))),
            TextButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    _addTask(
                        title: titleController.text,
                        description: descriptionController.text,
                        subject: selectedSubject,
                        color: selectedColor,
                        icon: selectedIcon,
                        dateTime: selectedDate);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Agregar', style: TextStyle(color: Colors.black))),
          ],
        );
      },
    );
  }
}
