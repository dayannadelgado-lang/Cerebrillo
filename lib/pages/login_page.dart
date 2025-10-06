//HARDY Y JOSUE ESTA PAGINA NO LA MODIFICARAN SE QUEDA COMO ESTA


// lib/pages/login_page.dart
// ignore_for_file: deprecated_member_use, duplicate_ignore, use_build_context_synchronously, unused_local_variable

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_page.dart';
import 'survey_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onThemeChanged});
  final void Function(bool isDark) onThemeChanged;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _borderAnimationController;
  late Animation<double> _borderAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _borderAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _borderAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _borderAnimationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _borderAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Por favor completa todos los campos")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'lastLogin': FieldValue.serverTimestamp(),
          'email': user.email ?? '',
        }, SetOptions(merge: true));

        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        bool surveyDone = userDoc.data()?['survey_done'] ?? false;

        if (surveyDone) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomePage(onThemeChanged: (bool isDark) {  },)));
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SurveyPage(
                onSurveyComplete: (answers) async {
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                    'survey_done': true,
                    'survey_answers': answers,
                    'timestamp': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));

                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomePage(onThemeChanged: (bool isDark) {  },)));
                },
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error desconocido";
      if (e.code == 'user-not-found') {
        message = "Usuario no encontrado.";
      } else if (e.code == 'wrong-password') {
        message = "Contraseña incorrecta.";
      } else if (e.code == 'invalid-email') {
        message = "Correo inválido.";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final String fondo = _isDark ? "assets/images/logindark.jpg" : "assets/images/login.jpg";

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(fondo, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Lottie.asset(
                          "assets/animations/ini.json",
                          width: 400,
                          height: 400,
                        ),
                        Lottie.asset(
                          "assets/animations/profile.json",
                          width: 200,
                          height: 200,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _isDark
                            ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "INICIAR SESIÓN",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Boogaloo",
                              fontSize: 26,
                              color: _isDark
                                  ? Colors.white
                                  : const Color.fromARGB(219, 216, 210, 234),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInput("Correo electrónico",
                              controller: _emailController),
                          const SizedBox(height: 16),
                          _buildInput("Contraseña",
                              obscure: true, controller: _passwordController),
                          const SizedBox(height: 24),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _buildHolographicButton(),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/register");
                            },
                            child: Text(
                              "¿No tienes cuenta? Regístrate",
                              style: TextStyle(
                                fontFamily: "JustAnotherHand",
                                fontSize: 20,
                                color: _isDark
                                    ? Colors.white
                                    : const Color.fromARGB(255, 216, 173, 231),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Switch de tema arriba derecha
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: Icon(
                    _isDark ? Icons.nights_stay : Icons.wb_sunny,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _isDark = !_isDark;
                    });
                    widget.onThemeChanged(_isDark);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String hint,
      {bool obscure = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: _isDark ? Colors.white : const Color.fromARGB(255, 0, 0, 0)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: "JustAnotherHand",
          fontSize: 20,
          color: _isDark ? Colors.white70 : Colors.black54,
        ),
        filled: true,
        fillColor: _isDark ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3) : Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildHolographicButton() {
    return AnimatedBuilder(
      animation: _borderAnimation,
      builder: (context, child) {
        final colors = _isDark
            ? [
                Color.lerp(Colors.blue[900], Colors.purple[900], _borderAnimation.value)!,
                Color.lerp(Colors.purple[900], Colors.black, _borderAnimation.value)!,
                Color.lerp(Colors.black, Colors.blue[900], _borderAnimation.value)!,
              ]
            : [
                Color.lerp(const Color(0xFFD3E6EA), const Color(0xFFCCD0F0), _borderAnimation.value)!,
                Color.lerp(const Color(0xFFC6CAF0), const Color(0xFFF3D0E1), _borderAnimation.value)!,
                Color.lerp(const Color(0xFFFAD3E6), const Color(0xFFEBD2EE), _borderAnimation.value)!,
              ];

        return GestureDetector(
          onTap: _loginUser,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(_borderAnimation.value * 2 * 3.14159),
              ),
              boxShadow: [
                BoxShadow(
                  color: _isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(-3, -3),
                ),
                BoxShadow(
                  color: _isDark ? Colors.blue.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Center(
                child: Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
