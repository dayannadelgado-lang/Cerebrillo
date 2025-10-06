import 'package:flutter/material.dart';
import '../utils/colors.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String lottieAsset;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
    this.lottieAsset = 'assets/animations/recordatorio.json',
  });

  Task copyWith({
    String? title,
    String? description,
    bool? isDone,
    DateTime? dueDate,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      lottieAsset: lottieAsset,
    );
  }

  Widget styledTile() {
    return ListTile(
      leading: SizedBox(
        height: 50,
        width: 50,
        child: Image.asset(lottieAsset), // si fuera Lottie, reemplazar con Lottie.asset
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
        description,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      trailing: Checkbox(
        value: isDone,
        onChanged: (val) {},
        activeColor: AppColors.accent,
      ),
    );
  }
}
