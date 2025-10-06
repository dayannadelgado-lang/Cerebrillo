// ignore_for_file: strict_top_level_inference, body_might_complete_normally_nullable

import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime reminderDate;
  Color color; // NUEVO: color para el calendario
  bool isCompleted; // mutable para poder marcar como completado

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.reminderDate,
    this.color = Colors.blueAccent,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'reminderDate': reminderDate.toIso8601String(),
        // ignore: deprecated_member_use
        'color': color.value,
        'isCompleted': isCompleted,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        reminderDate: DateTime.parse(json['reminderDate']),
        // ignore: deprecated_member_use
        color: Color(json['color'] ?? Colors.blueAccent.value),
        isCompleted: json['isCompleted'] ?? false,
      );

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? reminderDate,
    Color? color,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderDate: reminderDate ?? this.reminderDate,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Widget para mostrar recordatorio estilizado
  Widget styledCard() {
    return Card(
      // ignore: deprecated_member_use
      color: color.withOpacity(0.3),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                )),
            const SizedBox(height: 4),
            Text(description,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.black87,
                )),
            const SizedBox(height: 4),
            Text(
              'Recordatorio: ${reminderDate.hour.toString().padLeft(2, '0')}:${reminderDate.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static fromMap(Map<String, dynamic> data) {}

  Object? toMap() {}
}
