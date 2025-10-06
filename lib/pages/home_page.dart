// ESTA SI LA VAS A MODIFICAR JOSUE (AÑADI COMENTARIOS PARA GUIARTE)
// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unused_local_variable 

// IMPORTS
// Josue: aquí debes importar todas las páginas que realmente uses en el HomePage
// Solo importa lo que se usa aquí, no traigas archivos que no se ocupen
// Para el menú lateral seguramente tendrás que crear páginas nuevas más adelante.

import 'package:cerebrillo1/pages/meditacion_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tips_page.dart';
import 'reminders_page.dart';   // -> Ya importada pero aún sin diseño asi que esta es una que se mostrará en menú lateral cuando esté lista
import 'diary_page.dart';
import 'logros_page.dart';
import 'survey_page.dart';
import '../models/tip_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onThemeChanged});
  final void Function(bool isDark) onThemeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // VARIABLES DE USUARIO Y ESTADO
  // `_currentUser` obtiene al usuario de Firebase
  // `_userData` almacena la información de Firestore
  User? _currentUser;
  Map<String, dynamic>? _userData;

  // `_tappedIndex` es para detectar qué widget fue presionado y animarlo
  int _tappedIndex = -1;

  // `_isDark` controla el tema oscuro/claro
  bool _isDark = false;

  // Colores para el modo oscuro
  final Color azulDark = const Color.fromARGB(255, 38, 27, 154);

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserData(); // Se llama al inicio para traer los datos del usuario
  }

  // FUNCIÓN PARA TRAER DATOS DE USUARIO
  // Esta función consulta Firestore y revisa si el usuario ya completó la encuesta inicial
  // Si no, lo manda a `SurveyPage` y luego a `TipsPage`.
  Future<void> _fetchUserData() async {
    if (_currentUser != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
      if (doc.exists) {
        setState(() => _userData = doc.data());
        final surveyDone = _userData?['survey_done'] ?? false;
        if (!surveyDone) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SurveyPage(
                  onSurveyComplete: (List<int> answers) async {
                    // Guarda en Firestore que ya se hizo la encuesta
                    await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).set({
                      'survey_done': true,
                      'survey_answers': answers,
                      'timestamp': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));

                    // Después de encuesta -> manda a TipsPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TipsPage(
                          perfil: _userData?['name'] ?? 'Usuario',
                          tips: _generateTipsFromSurvey(answers),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          });
        }
      }
    }
  }

  // GENERADOR DE TIPS
  // Crea tips a partir de respuestas de la encuesta
  List<TipModel> _generateTipsFromSurvey(List<int> answers) {
    return answers.map((a) => TipModel(
      id: 'tip$a',
      title: 'Tip $a',
      subtitle: 'Tip basado en respuesta $a',
      lottieMain: 'assets/images/pomodoro.png',
      lottieOverlay: '',
      details: ['Detalle 1', 'Detalle 2'],
      imagePath: '',
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    // DATOS BÁSICOS DE INTERFAZ
    final userName = _userData?['name'] ?? "Usuario"; // Nombre del usuario
    final String fondo = _isDark ? "assets/images/home_darl.jpg" : "assets/images/home2.jpg"; // Fondo dinámico

    return Scaffold(
      //  JOSUE ACA DEBES AÑADIR MENÚ LATERAL (Drawer) TE DEJO UN CODIGO BASE OKEY
      // Aquí se podría activar el menú lateral (por ahora está SOLO VERSION comentario,ya que condirmes añadas cosas deberas modificarlo).
      // Puedes añadir más opciones al menú dependiendo de tus ideas
      // drawer: Drawer(
      //   child: ListView(
      //     children: [
      //       const DrawerHeader(
      //         child: Text("Menú de Opciones"),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.lightbulb),
      //         title: Text("Tips"),
      //         onTap: () => Navigator.push(context,
      //           MaterialPageRoute(builder: (_) => TipsPage(perfil: userName, tips: []))),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.menu_book),
      //         title: Text("Diario"),
      //         onTap: () => Navigator.push(context,
      //           MaterialPageRoute(builder: (_) => DiaryPage(userPassword: "", onThemeChanged: (_) {}))),
      //       ),
      //       //  Aquí puedes añadir más secciones como Logros, Recordatorios, Configuración
      //     ],
      //   ),
      // ),

      //  cuerpo PRINCIPAL
      body: Stack(
        children: [
          //  Fondo de pantalla dinámico (oscuro/claro)
          SizedBox.expand(
            child: Image.asset(fondo, fit: BoxFit.cover),
          ),

          //  Scroll de contenido
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const SizedBox(height: 70),

                // Animaciones de bienvenida pero no los modifiques dejalo como esta peri para que te des una idea de como se declaran
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset("assets/animations/ini1.json", width: 250, height: 250, repeat: true),
                    Lottie.asset("assets/animations/meditacion.json", width: 200, height: 200, repeat: true),
                    Image.asset('assets/images/mujer.png', height: 0),
                  ],
                ),

                const SizedBox(height: 8),

                //  Texto de saludo dinámico
                Text(
                  "Hola, $userName",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Montserrat",
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                //  Texto motivacional central
                const Text(
                  "CREE",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Montserrat",
                    color: Colors.white,
                  ),
                ),

                const Divider(
                  thickness: 1,
                  color: Colors.white70,
                  indent: 100,
                  endIndent: 100,
                ),

                const SizedBox(height: 4),

                const Text(
                  "Confía en ti, porque la persona capaz de lograrlo ya vive dentro de ti.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Bentham",
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                // GRID DE WIDGETS PRINCIPALES
                // Aquí se listan las secciones principales como Tips, Diario, etc.
                // Puedes añadir más, pero deberás ajustar el tamaño para que no se desborde,pero ya depende el acomode que le des
                GridView.count(
                  crossAxisCount: 2, // Cantidad de columnas
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.3, // Relación de aspecto de los cuadros
                  children: [
                    //  Widget Tips
                    _buildAnimatedOption(
                      index: 0,
                      icon: Icons.lightbulb_outline,
                      label: "TIPS",
                      page: TipsPage(
                        perfil: userName,
                        tips: _userData?['survey_answers'] != null
                            ? _generateTipsFromSurvey(List<int>.from(_userData!['survey_answers']))
                            : [],
                      ),
                      circleColor: _isDark ? azulDark : const Color.fromARGB(255, 255, 223, 245),
                    ),

                    //  Widget Diario
                    _buildAnimatedOption(
                      index: 1,
                      icon: Icons.menu_book,
                      label: "DIARIO",
                      page: DiaryPage(userPassword: "", onThemeChanged: (bool p1) {  },),
                      circleColor: _isDark ? azulDark : const Color.fromARGB(255, 255, 223, 245),
                    ),

                    //  Widget Meditación
                    _buildAnimatedOption(
                      index: 2,
                      icon: Icons.favorite,
                      label: "MEDITACION",
                      page: const MeditacionPage(),
                      circleColor: _isDark ? azulDark : const Color.fromARGB(255, 255, 223, 245),
                    ),

                    //  Widget Logros
                    _buildAnimatedOption(
                      index: 3,
                      icon: Icons.emoji_events,
                      label: "LOGROS",
                      page: const LogrosPage(),
                      circleColor: _isDark ? azulDark : const Color.fromARGB(255, 255, 223, 245),
                    ),

                    // Ejemplo: Widget Recordatorios (ejemplo por si quieres añadir mas)
                    // _buildAnimatedOption(
                    //   index: 4,
                    //   icon: Icons.alarm,
                    //   label: "RECORDATORIOS",
                    //   page: RemindersPage(),
                    //   circleColor: _isDark ? azulDark : Colors.pinkAccent,
                    // ),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),

          //  SWITCH DE TEMA
          // Botón arriba derecha para cambiar entre tema oscuro y claro
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                  icon: Icon(
                    _isDark ? Icons.nights_stay : Icons.wb_sunny,  // Cambia el ícono dependiendo del tema
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

  // FUNCIÓN PARA CREAR LOS CUADRITOS DEL GRID
  // Esta función lo que hace es que  construye los cuadros animados (Tips, Diario, etc.)
  // La puedes reutilizar para añadir más secciones
  Widget _buildAnimatedOption({
    required int index,
    required IconData icon,
    required String label,
    required Widget page,
    required Color circleColor,
  }) {
    final isTapped = _tappedIndex == index;
    return GestureDetector(
      onTapDown: (_) => setState(() => _tappedIndex = index),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() => _tappedIndex = -1);
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        });
      },
      onTapCancel: () => setState(() => _tappedIndex = -1),
      child: AnimatedScale(
        scale: isTapped ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isDark
                ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isTapped
                    ? circleColor.withOpacity(0.4)
                    : const Color.fromARGB(66, 255, 255, 255),
                blurRadius: isTapped ? 15 : 6,
                spreadRadius: isTapped ? 3 : 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                  color: _isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
