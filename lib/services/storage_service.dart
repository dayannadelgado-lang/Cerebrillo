import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';

class StorageService {
  static const String _keyReminders = 'reminders';

  // Guardar lista de recordatorios
  static Future<void> saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = reminders.map((r) => json.encode(r.toJson())).toList();
    await prefs.setStringList(_keyReminders, jsonList);
  }

  // Obtener lista de recordatorios
  static Future<List<Reminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyReminders) ?? [];
    return jsonList
        .map((jsonStr) => Reminder.fromJson(json.decode(jsonStr)))
        .toList();
  }

  // Agregar un recordatorio
  static Future<void> addReminder(Reminder reminder) async {
    final reminders = await getReminders();
    reminders.add(reminder);
    await saveReminders(reminders);
  }

  // Eliminar un recordatorio
  static Future<void> deleteReminder(String id) async {
    final reminders = await getReminders();
    reminders.removeWhere((r) => r.id == id);
    await saveReminders(reminders);
  }
}
