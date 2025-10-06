import 'package:flutter/material.dart';

/// Paleta de colores global de Cerebrillo
class AppColors {
  // ====== Colores principales ======
  static const Color primary = Color.fromARGB(255, 255, 143, 205);     // Morado principal
  static const Color secondary = Color.fromARGB(255, 255, 185, 199);   // Rosa acento
  static const Color accent = Color.fromARGB(255, 255, 204, 211);      // Verde turquesa

  // ====== Fondos ======
  static const Color background = Color(0xFFF5F5F5);  // Fondo claro general
  static const Color surface = Colors.white;          // Tarjetas, contenedores
  static const Color backgroundCard = Color(0xFFFFFFFF); // Fondo específico para tarjetas/notas

  // ====== Texto ======
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textLight = Colors.white;

  // ====== Estados ======
  static const Color success = Color(0xFF4CAF50);     // Verde éxito
  static const Color warning = Color(0xFFFFC107);     // Amarillo advertencia
  static const Color error = Color(0xFFF44336);       // Rojo error
  static const Color info = Color(0xFF2196F3);        // Azul info

  // ====== Sombras y bordes ======
  static const Color shadow = Colors.black26;
  static const Color border = Color(0xFFE0E0E0);

  // ====== Gradientes ======
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ====== Otros colores útiles ======
  static const Color cardBorder = Color(0xFFCCCCCC);  // Borde de tarjetas
  static const Color shadowLight = Color(0x33000000); // Sombra ligera
}
