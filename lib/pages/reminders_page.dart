//HARDY ESTA ES PARA RECORDATORIOS AÑADE UNA FUNCION QUE MANDE UNA NOTIFICACION AL USUARIO PARA RECORDARLO,MODIFICARAS EL DISEÑO 
//PARA QUE TENGA SIMILITUD CON LAS DEMAS PAGINAS


// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/reminder_model.dart'; // Modelo de Reminder (id, título, descripción, fecha, completado)
import '../utils/colors.dart'; // Colores de la app
import 'package:cloud_firestore/cloud_firestore.dart'; // Para guardar datos en Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el usuario actual

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  RemindersPageState createState() => RemindersPageState();
}

class RemindersPageState extends State<RemindersPage> {
  List<Reminder> reminders = []; // Lista de recordatorios del usuario
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser; // Usuario logueado

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _loadReminders(); // Cargar recordatorios al iniciar la página
    }
  }

  /// 🔹 Cargar recordatorios desde Firestore
  Future<void> _loadReminders() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('reminders')
        .orderBy('reminderDate', descending: false)
        .get();

    setState(() {
      // Convertimos los documentos de Firestore a objetos Reminder
      reminders = snapshot.docs.map((doc) {
        final data = doc.data();
        return Reminder(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          reminderDate: (data['reminderDate'] as Timestamp).toDate(),
          isCompleted: data['isCompleted'] ?? false,
        );
      }).toList();
    });
  }

  ///  Agregar un nuevo recordatorio
  Future<void> _addReminder(Reminder reminder) async {
    if (currentUser == null) return;

    // Guardar en Firestore
    final docRef = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('reminders')
        .add({
      'title': reminder.title,
      'description': reminder.description,
      'reminderDate': reminder.reminderDate,
      'isCompleted': reminder.isCompleted,
    });

    // Actualizar lista local para mostrar inmediatamente
    setState(() {
      reminders.add(reminder.copyWith(id: docRef.id));
    });

    // AQUÍ PODRÍAS LLAMAR UNA FUNCIÓN PARA ENVIAR NOTIFICACIÓN LOCAL
    // Ejemplo: _scheduleNotification(reminder);
  }

  /// Marcar un recordatorio como completado / pendiente
  Future<void> _toggleCompleted(int index) async {
    final reminder = reminders[index];
    final newStatus = !reminder.isCompleted;

    if (currentUser != null) {
      // Actualizar en Firestore
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('reminders')
          .doc(reminder.id)
          .update({'isCompleted': newStatus});
    }

    // Actualizar estado local
    setState(() {
      reminders[index] = reminder.copyWith(isCompleted: newStatus);
    });
  }

  ///  Mostrar diálogo para agregar recordatorio
  void _showAddReminderDialog() {
    String title = '';
    String description = '';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo recordatorio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input título
            TextField(
              decoration: const InputDecoration(labelText: 'Título'),
              onChanged: (val) => title = val,
            ),
            // Input descripción
            TextField(
              decoration: const InputDecoration(labelText: 'Descripción'),
              onChanged: (val) => description = val,
            ),
            const SizedBox(height: 12),
            // Botón para seleccionar fecha y hora
            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  final pickedTime = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (pickedTime != null) {
                    selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute);
                  }
                }
              },
              child: const Text('Seleccionar fecha y hora'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  // Agregar recordatorio
                  _addReminder(Reminder(
                    id: '',
                    title: title,
                    description: description,
                    reminderDate: selectedDate,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Agregar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recordatorios'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: reminders.isEmpty
          ? const Center(
              child: Text(
                'No hay recordatorios',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return GestureDetector(
                  onTap: () => _toggleCompleted(index), // Marca completado al tocar
                  child: Opacity(
                    opacity: reminder.isCompleted ? 0.5 : 1.0,
                    child: reminder.styledCard(), // Método que devuelve un Card con diseño del recordatorio
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog, // Abrir diálogo para agregar nuevo recordatorio
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // HARDY AQUÍ PUEDES AÑADIR FUNCIONES PARA NOTIFICACIONES
  // Ejemplo:
  // void _scheduleNotification(Reminder reminder) { ... }
}
