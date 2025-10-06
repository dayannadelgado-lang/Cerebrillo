//HARDY ESTE ESTARA VINCULADO CON LOS RECORDATORIOS SI EL USUARIO REGISTRA FECHA SE MOSTARA EN CALENDARIO Y AL DARLE CLIK AL DIA DEBERA 
//MOSTRARSE LA INFORMACION DETALLADA DEL RECORDATORIO ASI QUE PARA ELLO MODIFICARAS TANTO DISEÑO Y LOGICA EL CODIGO ES MAS COMO BASE FALTA MAS COSAS 


// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final reminders = reminderProvider.getRemindersByDate(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Recordatorios del ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return ListTile(
                  title: Text(reminder.title),
                  subtitle: Text(reminder.description),
                  trailing: Checkbox(
                    value: reminder.isCompleted,
                    onChanged: (value) async {
                      reminderProvider.toggleCompleted(reminder);
                      await _updateFirestoreCompletion(reminder);
                    },
                  ),
                  onTap: () async {
                    final action = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Opciones'),
                          content: const Text('¿Qué deseas hacer con este recordatorio?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'edit'),
                              child: const Text('Editar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'delete'),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        );
                      },
                    );

                    if (action == 'delete') {
                      reminderProvider.deleteReminder(reminder.id);
                      await _deleteFirestoreReminder(reminder.id);
                    } else if (action == 'edit') {
                      // Aquí puedes implementar el diálogo de edición
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String title = '';
          String description = '';
          DateTime date = _selectedDay;

          final newReminder = await showDialog<Reminder>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Nuevo Recordatorio'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Título'),
                    onChanged: (value) => title = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    onChanged: (value) => description = value,
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) date = picked;
                    },
                    child: const Text('Seleccionar fecha'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (title.isNotEmpty) {
                      Navigator.pop(
                        context,
                        Reminder(
                          id: const Uuid().v4(),
                          title: title,
                          description: description,
                          reminderDate: date,
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          );

          if (newReminder != null) {
            reminderProvider.addReminder(
              title: newReminder.title,
              description: newReminder.description,
              reminderDate: newReminder.reminderDate,
            );
            await _saveFirestoreReminder(newReminder);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Guardar recordatorio en Firestore bajo UID del usuario
  Future<void> _saveFirestoreReminder(Reminder reminder) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('recordatorios')
            .doc(reminder.id)
            .set({
          'title': reminder.title,
          'description': reminder.description,
          'reminderDate': reminder.reminderDate,
          'isCompleted': reminder.isCompleted,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("❌ Error guardando recordatorio en Firestore: $e");
    }
  }

  /// 🔹 Actualiza el estado de completado en Firestore
  Future<void> _updateFirestoreCompletion(Reminder reminder) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('recordatorios')
            .doc(reminder.id)
            .update({'isCompleted': reminder.isCompleted});
      }
    } catch (e) {
      debugPrint("❌ Error actualizando completado en Firestore: $e");
    }
  }

  /// Elimina recordatorio en Firestore
  Future<void> _deleteFirestoreReminder(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('recordatorios')
            .doc(id)
            .delete();
      }
    } catch (e) {
      debugPrint("❌ Error eliminando recordatorio en Firestore: $e");
    }
  }
}
