
//HARDY Y JOSUE ESTA PAGINA ES DE CONFIGURACION  Y DEBERAN MODIFICAR EL DISEÑP

import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Página de Configuración donde el usuario puede modificar preferencias
/// como modo oscuro y notificaciones
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //  Variables que almacenan las preferencias del usuario
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  //  Conexión a Firestore y usuario actual
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    //  Cargar las preferencias guardadas al iniciar la página
    _loadSettings();
  }

  ///  Función para cargar preferencias del usuario desde Firestore
  Future<void> _loadSettings() async {
    if (currentUser == null) return;

    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        // Asigna los valores guardados o usa valores por defecto
        isDarkMode = data?['settings']?['darkMode'] ?? false;
        notificationsEnabled = data?['settings']?['notifications'] ?? true;
      });
    }
  }

  /// Función para actualizar una preferencia específica en Firestore
  Future<void> _updateSetting(String key, dynamic value) async {
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser!.uid).set(
      {
        'settings': {key: value} //  Guarda solo la preferencia cambiada
      },
      SetOptions(merge: true), //  No sobrescribe otras configuraciones
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: AppColors.primary, //  Color de barra superior
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de la sección
            const Text(
              'Preferencias',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Interruptor para activar/desactivar modo oscuro
            SwitchListTile(
              title: const Text('Modo oscuro'),
              value: isDarkMode,
              onChanged: (val) {
                setState(() => isDarkMode = val); // 🔹 Actualiza UI
                _updateSetting('darkMode', val);   // 🔹 Guarda en Firestore
              },
            ),

            //  Interruptor para activar/desactivar notificaciones
            SwitchListTile(
              title: const Text('Notificaciones'),
              value: notificationsEnabled,
              onChanged: (val) {
                setState(() => notificationsEnabled = val); // 🔹 Actualiza UI
                _updateSetting('notifications', val);       // 🔹 Guarda en Firestore
              },
            ),
          ],
        ),
      ),
    );
  }
}
