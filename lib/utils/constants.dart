import 'package:flutter/material.dart';

class AppConstants {
  // ================= PATHS =================
  static const String lottieLogo = "assets/animations/cerebrillologo.json";
  static const String appIcon = "assets/images/app_icon.png";

  // ================= ANIMATIONS =================
  static const double splashAnimationSize = 200.0;
  static const Duration splashDuration = Duration(seconds: 3);

  // ================= UI =================
  static const double padding = 16.0;
  static const double borderRadius = 12.0;

  // ================= TEXT =================
  static const String appName = "Cerebrillo";
  static const String defaultFontFamily = "Poppins";

  // ================= KEYS / STORAGE =================
  static const String keyUser = "user";
  static const String keyNotes = "notes";
  static const String keyTasks = "tasks";
  static const String keyHabits = "habits";
  static const String keyReminders = "reminders";
  static const String keySurvey = "survey";

  // ================= COLORS =================
  static const Color primaryColor = Color(0xFF4A90E2); // Azul principal
  static const Color secondaryColor = Color(0xFFF5A623); // Naranja secundario
  static const Color backgroundColor = Color(0xFFF2F2F2); // Fondo general
  static const Color textColor = Color(0xFF333333); // Texto principal
  static const Color cardColor = Color(0xFFFFFFFF); // Fondo de tarjetas
}

