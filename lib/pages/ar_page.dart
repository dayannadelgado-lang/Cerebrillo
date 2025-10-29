import 'package:flutter/material.dart';
// ignore: unused_import
import '../utils/colors.dart';

import '../ar_viewer_screen.dart';     // V1 (Web)
import '../ar_marker_ml_screen.dart'; // V2 (ML Kit)
import '../ar_native_screen.dart';      // V3 (Nativa)

class ARPage extends StatelessWidget {
  const ARPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos el color de tu marca para reusarlo
    const Color brandColor = Color.fromARGB(255, 255, 136, 182);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Cerebrillo'),
        backgroundColor: brandColor,
      ),
      
      // 2. REEMPLAZAMOS EL BODY CON UNA LISTA DE BOTONES
      // Usamos ListView para que se pueda desplazar en pantallas pequeñas
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // --- Botón para la Versión 1 ---
          _buildARButton(
            context: context,
            title: 'V1: Visor Web (Cerebro)',
            subtitle: 'Multiplataforma. Rápido y ligero.',
            icon: Icons.public,
            color: brandColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ARViewerScreen(
                    modelUrl: "httpsS://modelviewer.dev/shared-assets/models/BrainStem.glb",
                    iosModelUrl: "https://modelviewer.dev/shared-assets/models/BrainStem.usdz",
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20), // Espaciador

          // --- Botón para la Versión 2 ---
          _buildARButton(
            context: context,
            title: 'V2: Escáner de Marcador (ML)',
            subtitle: 'Multiplataforma. Reconoce imágenes.',
            icon: Icons.document_scanner_outlined,
            color: brandColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ARMarkerMLScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 20), // Espaciador

          // --- Botón para la Versión 3 ---
          _buildARButton(
            context: context,
            title: 'V3: RA Nativa (ARCore/ARKit)',
            subtitle: 'Android/iOS. Máxima potencia.',
            icon: Icons.view_in_ar,
            color: brandColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ARNativeScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET DE AYUDA PARA CREAR LOS BOTONES ---
  // (Lo pongo aquí mismo para mantenerlo simple)
  Widget _buildARButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(26), // Color de fondo suave
        foregroundColor: color, // Color del texto y del icono
        elevation: 0, // Sin sombra
        padding: const EdgeInsets.all(20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: color, width: 1.5), // Borde del color
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}