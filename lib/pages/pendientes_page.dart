// ignore_for_file: depend_on_referenced_packages, deprecated_member_use, unnecessary_null_in_if_null_operators, use_build_context_synchronously, strict_top_level_inference, unused_local_variable

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'home_page.dart';

class PendientesPage extends StatefulWidget {
  const PendientesPage({super.key});

  @override
  PendientesPageState createState() => PendientesPageState();
}

class PendientesPageState extends State<PendientesPage>
    with TickerProviderStateMixin {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> pendientes = [];
  late AnimationController _holoController;
  int _selectedBottomIndex = 2;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadPendientesFromFirestore();

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
          'pendientes_channel',
          'Pendientes',
          channelDescription: 'Notificaciones de pendientes',
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

  Future<void> _loadPendientesFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('pendientes')
        .get();

    setState(() {
      pendientes = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'text': doc.data()['text'] ?? '',
                'color': doc.data()['color'] ?? Colors.purple.value,
                'icon': doc.data()['icon'] ?? Icons.check.codePoint,
                'scheduledDate': doc.data()['scheduledDate'] ?? null,
              })
          .toList();
    });
  }

  Future<void> _addPendiente({
    required String text,
    required Color color,
    required IconData icon,
    required DateTime dateTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('pendientes')
        .add({
      'text': text,
      'color': color.value,
      'icon': icon.codePoint,
      'scheduledDate': dateTime.toIso8601String(),
    });

    setState(() {
      pendientes.add({
        'id': docRef.id,
        'text': text,
        'color': color.value,
        'icon': icon.codePoint,
        'scheduledDate': dateTime.toIso8601String()
      });
    });

    _scheduleNotification(
        id: pendientes.length,
        title: 'Pendiente: $text',
        body: '¡No olvides cumplir tu pendiente!',
        scheduledDate: dateTime);
  }

  Future<void> _removePendiente(Map<String, dynamic> pendiente) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('pendientes')
        .doc(pendiente['id'])
        .delete();

    _cancelNotification(pendientes.indexOf(pendiente) + 1);

    setState(() {
      pendientes.remove(pendiente);
    });
  }

  void _posponerPendiente(Map<String, dynamic> pendiente) async {
    DateTime selectedDate = DateTime.now().add(const Duration(minutes: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null) {
        selectedDate = DateTime(
            date.year, date.month, date.day, time.hour, time.minute);
        _updatePendienteDate(pendiente, selectedDate);
      }
    }
  }

  Future<void> _updatePendienteDate(
      Map<String, dynamic> pendiente, DateTime newDate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('pendientes')
        .doc(pendiente['id'])
        .update({'scheduledDate': newDate.toIso8601String()});

    _cancelNotification(pendientes.indexOf(pendiente) + 1);

    _scheduleNotification(
        id: pendientes.indexOf(pendiente) + 1,
        title: 'Pendiente: ${pendiente['text']}',
        body: '¡No olvides cumplir tu pendiente!',
        scheduledDate: newDate);

    _loadPendientesFromFirestore();
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
                // BOTÓN HOME HOLOGRÁFICO
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
                          icon: const Icon(Icons.home, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      HomePage(onThemeChanged: (bool val) {})),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                // BOTÓN + HOLOGRÁFICO
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
                          onPressed: _showAddPendienteDialog,
                        ),
                      );
                    },
                  ),
                ),
                // TITULO PENDIENTES
                Center(
                  child: Text(
                    'PENDIENTES',
                    style: const TextStyle(
                        fontFamily: 'LuckiestGuy-Regular',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                // LISTA PENDIENTES
                Positioned(
                  top: 120,
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: ListView.builder(
                    itemCount: pendientes.length,
                    itemBuilder: (context, index) {
                      final pendiente = pendientes[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ListTile(
                          leading: Icon(
                            IconData(pendiente['icon'],
                                fontFamily: 'MaterialIcons'),
                            color: Color(pendiente['color']),
                          ),
                          title: Text(
                            pendiente['text'],
                            style: TextStyle(
                                color: Color(pendiente['color']),
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.access_time,
                                      color: Colors.white),
                                  onPressed: () =>
                                      _posponerPendiente(pendiente)),
                              IconButton(
                                  icon:
                                      const Icon(Icons.check, color: Colors.white),
                                  onPressed: () => _removePendiente(pendiente)),
                            ],
                          ),
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
                      gradient: LinearGradient(
                        colors: [lerpColor1, lerpColor2],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: lerpColor1.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child:
                        const Icon(Icons.list, color: Colors.white, size: 36),
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

  void _showAddPendienteDialog() {
    final TextEditingController controller = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(minutes: 1));
    Color selectedColor = Colors.purple;
    IconData selectedIcon = Icons.check;

    final List<Color> colors = [
      Colors.purple,
      Colors.pink,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.cyan,
      Colors.teal.shade200,
      Colors.lime.shade200,
      Colors.pink.shade100,
      Colors.purple.shade100,
      Colors.orange.shade200,
      Colors.blue.shade200,
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
      Icons.airplanemode_active,
      Icons.camera_alt,
      Icons.cake,
      Icons.sports_soccer,
      Icons.movie,
      Icons.wb_sunny,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Agregar pendiente',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                      labelText: 'Título',
                      labelStyle: TextStyle(color: Colors.black54)),
                ),
                const SizedBox(height: 10),
                ColorPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (color) => setState(() => selectedColor = color),
                  showLabel: true,
                  pickerAreaHeightPercent: 0.7,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: icons
                      .map((i) => GestureDetector(
                            onTap: () => setState(() => selectedIcon = i),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Icon(
                                  i,
                                  color: selectedIcon == i ? selectedColor : Colors.grey[600],
                                  size: 32,
                                ),
                                if (selectedIcon == i)
                                  const Positioned(
                                    top: -6,
                                    child: Icon(
                                      Icons.arrow_drop_up,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100));
                    if (date != null) {
                      final time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        selectedDate = DateTime(date.year, date.month, date.day,
                            time.hour, time.minute);
                      }
                    }
                  },
                  child: const Text('Seleccionar fecha y hora'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.black))),
            TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    _addPendiente(
                        text: controller.text,
                        color: selectedColor,
                        icon: selectedIcon,
                        dateTime: selectedDate);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Agregar',
                    style: TextStyle(color: Colors.black))),
          ],
        );
      },
    );
  }
}
