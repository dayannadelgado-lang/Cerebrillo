import 'package:flutter/material.dart';
import '../utils/colors.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String avatar; // ruta del Lottie del avatar
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  // Método de copia para actualizar usuario
  User copyWith({
    String? name,
    String? email,
    String? avatar,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Método de estilo de texto del nombre
  Text styledName() {
    return Text(
      name,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}
