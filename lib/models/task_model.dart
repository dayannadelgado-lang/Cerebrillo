import 'package:flutter/material.dart';
import '../utils/colors.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String subject; // Materia de la tarea
  final bool isDone;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String lottieAsset;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.subject, // obligatorio ahora
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
    this.lottieAsset = 'assets/animations/recordatorio.json',
  });

  Task copyWith({
    String? title,
    String? description,
    String? subject,
    bool? isDone,
    DateTime? dueDate,
    String? lottieAsset,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      lottieAsset: lottieAsset ?? this.lottieAsset,
    );
  }

  /// Widget estilizado para mostrar la tarea en la lista
  Widget styledTile({VoidCallback? onTap, ValueChanged<bool?>? onChanged}) {
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        height: 50,
        width: 50,
        child: Image.asset(lottieAsset), // reemplazar con Lottie.asset si quieres animación real
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      subtitle: Text(
        '$description\nMateria: $subject',
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      trailing: Checkbox(
        value: isDone,
        onChanged: onChanged,
        activeColor: AppColors.accent,
      ),
    );
  }

  /// Convierte la tarea a un Map para guardar en Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'isDone': isDone,
      'createdAt': createdAt,
      'dueDate': dueDate,
      'lottieAsset': lottieAsset,
    };
  }

  /// Crea una tarea a partir de un Map de Firebase
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? 'General',
      isDone: map['isDone'] ?? false,
      createdAt: (map['createdAt'] as dynamic).toDate(),
      dueDate: map['dueDate'] != null ? (map['dueDate'] as dynamic).toDate() : null,
      lottieAsset: map['lottieAsset'] ?? 'assets/animations/recordatorio.json',
    );
  }
}
