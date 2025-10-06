//JOSUE ESTA PAGINA DEBERAS EDITARLA ES PARTE DEL MENU LATERAL TE SALDRA LA INFORMACION DEL USUARIO ACA TAMBIEN PODRAS HACER ...
//UNA SELECCION PERSONALIZADA DONDE EL USUARIO PUEDA ESCOGER UN AVATAR DE PERFIL HAY IMAGENES YA CARGADAS DE EJEMPLOS PUEDES USARLAS ESTAN EN ASSETS
// EL DISEÑO DEBERAS MODIFICARLO PORQUE ES SOLO SIMPLE
//Su función principal es mostrar la información del usuario que está logueado y dar acceso a la configuración 


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String displayName = "Usuario Cerebrillo";
  String email = "usuario@cerebrillo.com";
  String photoUrl = "assets/images/app_icon.png";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Cargar datos del usuario desde FirebaseAuth y Firestore
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      displayName = user.displayName ?? displayName;
      email = user.email ?? email;
      photoUrl = user.photoURL ?? photoUrl;
    });

    // Opcional: cargar info personalizada desde Firestore
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        displayName = data['displayName'] ?? displayName;
        email = data['email'] ?? email;
        photoUrl = data['photoUrl'] ?? photoUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: photoUrl.startsWith('http')
                  ? NetworkImage(photoUrl)
                  : AssetImage(photoUrl) as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(displayName,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(email,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Card(
              color: AppColors.backgroundCard,
              child: ListTile(
                leading: const Icon(Icons.settings, color: AppColors.primary),
                title: const Text('Configuración'),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
