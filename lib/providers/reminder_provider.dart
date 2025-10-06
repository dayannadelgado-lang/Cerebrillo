import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

class ReminderProvider with ChangeNotifier {
  final List<Reminder> _reminders = [];

  List<Reminder> get reminders => _reminders;

  // Agregar nuevo recordatorio
  void addReminder({
    required String title,
    required String description,
    required DateTime reminderDate,
  }) {
    final newReminder = Reminder(
      id: const Uuid().v4(),
      title: title,
      description: description,
      reminderDate: reminderDate,
    );
    _reminders.add(newReminder);
    notifyListeners();
  }

  // Editar recordatorio existente
  void editReminder(Reminder reminder, {
    String? title,
    String? description,
    DateTime? reminderDate,
  }) {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        title: title,
        description: description,
        reminderDate: reminderDate,
      );
      notifyListeners();
    }
  }

  // Eliminar recordatorio
  void deleteReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Marcar recordatorio como completado
  void toggleCompleted(Reminder reminder) {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        isCompleted: !reminder.isCompleted,
      );
      notifyListeners();
    }
  }

  // Obtener recordatorios de un día específico
  List<Reminder> getRemindersByDate(DateTime date) {
    return _reminders.where((r) =>
        r.reminderDate.year == date.year &&
        r.reminderDate.month == date.month &&
        r.reminderDate.day == date.day).toList();
  }
}
