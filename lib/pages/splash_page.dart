// ESTA PAGINA SE QUEDA COMO ESTA 


// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/colors.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    User? user = _auth.currentUser;

    if (user != null) {
      // Usuario logueado, podemos cargar datos de Firestore si quieres
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Aquí podrías guardar datos del usuario en un provider o localmente
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(onThemeChanged: (bool isDark) {  },)),
      );
    } else {
      // Usuario no logueado, ir a Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(onThemeChanged: (bool isDark) {  },)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Lottie.asset(
          'assets/animations/cerebrillologo.json',
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
