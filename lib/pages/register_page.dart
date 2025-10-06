//HARDY Y JOSUE ESTA PAGINA SE QUEDA COMO ESTA NO LA MODIFICARAN



// lib/pages/register_page.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_import, unused_field, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'survey_page.dart';
import 'home_page.dart';
import 'tips_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tip_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.onThemeChanged});
  final void Function(bool isDark) onThemeChanged;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  late AnimationController _buttonController;
  late Animation<double> _buttonFloatAnimation;
  late Animation<double> _buttonPressAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: 0, end: 16).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _buttonController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _buttonFloatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    _buttonPressAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _buttonController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'diaryPassword': '',
          'reminders': [],
          'achievements': [],
          'tasks': [],
          'tips': [],
          'notifications': [],
        });

        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        bool surveyDone = userDoc.data()?['survey_done'] ?? false;

        if (surveyDone) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(onThemeChanged: (bool isDark) {  },)));
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SurveyPage(
                onSurveyComplete: (List<int> answers) async {
                  await FirebaseFirestore.instance.collection('users').doc(uid).set({
                    'survey_done': true,
                    'survey_answers': answers,
                    'timestamp': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TipsPage(
                        perfil: name,
                        tips: _generateTipsFromSurvey(answers),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error desconocido";
      if (e.code == 'email-already-in-use') message = "El correo ya está en uso.";
      else if (e.code == 'weak-password') message = "La contraseña es muy débil.";
      else if (e.code == 'invalid-email') message = "Correo inválido.";

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<TipModel> _generateTipsFromSurvey(List<int> answers) {
    return answers.map((a) {
      return TipModel(
        id: "tip$a",
        title: "Tip general para respuesta $a",
        subtitle: "Subtítulo para respuesta $a",
        lottieMain: "assets/animations/ini1.json",
        lottieOverlay: "",
        details: ["Detalle 1", "Detalle 2"],
        imagePath: "",
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final String fondo = _isDark ? "assets/images/fondodark.jpg" : "assets/images/fondo.jpg";
    final String imgRegistro = _isDark ? "assets/images/registrodark.png" : "assets/images/registro.png";

    // ✅ Campos de texto
    final Color textFieldColor = _isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3);
    final Color textFieldTextColor = _isDark ? Colors.white : Colors.black;

    // ✅ Botón registrar
    final List<Color> buttonColors = _isDark
        ? [const Color(0xFF000000), const Color(0xFF0A3D91)] // negro y azul fuerte
        : [const Color.fromARGB(255, 253, 210, 232), const Color.fromARGB(255, 233, 196, 240)];

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          SizedBox.expand(
            child: Image.asset(fondo, fit: BoxFit.cover),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.7,
                        height: screenWidth * 0.7,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            IgnorePointer(
                              ignoring: true,
                              child: Lottie.asset(
                                "assets/animations/ini1.json",
                                width: screenWidth * 0.6,
                                height: screenWidth * 0.6,
                                fit: BoxFit.contain,
                                repeat: true,
                              ),
                            ),
                            IgnorePointer(
                              ignoring: true,
                              child: Image.asset(
                                imgRegistro,
                                width: screenWidth * 0.40,
                                height: screenWidth * 0.40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_floatingAnimation.value),
                          child: Center(
                            child: Stack(
                              children: [
                                Text(
                                  "CEREBRILLO",
                                  style: TextStyle(
                                    fontFamily: 'Boogaloo',
                                    fontSize: 40,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 3
                                      ..color = const Color.fromARGB(255, 254, 251, 251),
                                  ),
                                ),
                                Text(
                                  "CEREBRILLO",
                                  style: TextStyle(
                                    fontFamily: 'Boogaloo',
                                    fontSize: 40,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // TextFields
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: textFieldTextColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldColor,
                        hintText: "Nombre completo",
                        hintStyle: TextStyle(color: textFieldTextColor.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: textFieldTextColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldColor,
                        hintText: "Correo electrónico",
                        hintStyle: TextStyle(color: textFieldTextColor.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: textFieldTextColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldColor,
                        hintText: "Contraseña",
                        hintStyle: TextStyle(color: textFieldTextColor.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón Registrar
                    Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_buttonFloatAnimation, _buttonPressAnimation]),
                        builder: (context, child) {
                          double floatY = -_buttonFloatAnimation.value;
                          double scale = _buttonPressAnimation.value;
                          return Transform.translate(
                            offset: Offset(0, floatY),
                            child: Transform.scale(
                              scale: scale,
                              child: GestureDetector(
                                onTapDown: (_) => _buttonController.forward(from: 0.0),
                                onTapUp: (_) => _buttonController.reverse(from: 1.0),
                                onTapCancel: () => _buttonController.reverse(from: 1.0),
                                onTap: _registerUser,
                                child: Container(
                                  width: 180,
                                  height: 60,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: LinearGradient(
                                      colors: buttonColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.6),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "REGISTRAR",
                                    style: TextStyle(
                                      fontFamily: 'Boogaloo',
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Color.fromARGB(169, 246, 216, 230),
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "¿Ya tienes cuenta? Inicia sesión",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "© 2025 Cerebrillo",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
}
