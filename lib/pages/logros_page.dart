//HARDY Y JOSUE ESTA PAGINA NO LA MODIFICARAN SE QUEDA COMO ESTA



// lib/pages/logros_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogrosPage extends StatefulWidget {
  final Function(bool)? onThemeChanged; // 🔹 para notificar al main
  const LogrosPage({super.key, this.onThemeChanged});

  @override
  LogrosPageState createState() => LogrosPageState();
}

class LogrosPageState extends State<LogrosPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> logros = [];
  bool showCongrats = false;
  bool _isDark = false; // 🔹 tema actual

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _loadLogrosFromFirestore();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadLogrosFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('logros')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        logros = snapshot.docs
            .map((doc) => {
                  'titulo': doc['titulo'],
                  'icono': doc['icono'] ?? Icons.star.codePoint,
                  'color': Color(doc['color'] ??
                      const Color.fromARGB(255, 255, 7, 131).value),
                  'fecha': (doc['fecha'] as Timestamp?)?.toDate(),
                  'id': doc.id,
                })
            .toList();
      });
    } catch (e) {
      debugPrint("❌ Error cargando logros: $e");
    }
  }

  Future<void> addLogro(
      String titulo, IconData icono, Color color, DateTime fecha) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      logros.insert(0, {
        'titulo': titulo,
        'icono': icono.codePoint,
        'color': color,
        'fecha': fecha,
      });
      showCongrats = true;
    });

    _scaleController.forward(from: 0);

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('logros')
          .add({
        'titulo': titulo,
        'icono': icono.codePoint,
        'color': color.value,
        'fecha': fecha,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("❌ Error guardando logro: $e");
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => showCongrats = false);
      }
    });
  }

  Future<void> deleteLogro(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('logros')
          .doc(id)
          .delete();
      _loadLogrosFromFirestore();
    } catch (e) {
      debugPrint("❌ Error borrando logro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Fondo dinámico
          Positioned.fill(
            child: Image.asset(
              _isDark
                  ? "assets/images/fondologrodark.jpg"
                  : "assets/images/fondologro1.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Switch tema arriba derecha (encima de Lotties)
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
                    if (widget.onThemeChanged != null) {
                      widget.onThemeChanged!(_isDark);
                    }
                  },
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🔹 Superposición de Lotties
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset("assets/animations/ini.json", height: 150),
                    Lottie.asset("assets/animations/ini1.json", height: 200),
                    Image.asset("assets/images/logro.png", height: 150),
                  ],
                ),
                const SizedBox(height: 1),

                // 🔹 Texto LOGROS
                Text(
                  "LOGROS",
                  style: TextStyle(
                    fontFamily: 'Bentham',
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // 🔹 Lista de logros
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: logros.length,
                    itemBuilder: (context, index) {
                      final logro = logros[index];
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: _isDark
                                  ? Colors.black
                                  : Colors.white,
                              title: Text(
                                "¿Deseas borrar este logro?",
                                style: TextStyle(
                                    fontFamily: 'Boogaloo',
                                    color: _isDark
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Cancelar",
                                    style: TextStyle(
                                        fontFamily: 'Boogaloo',
                                        color: Colors.blueAccent),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent),
                                  onPressed: () {
                                    deleteLogro(logro['id']);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Aceptar",
                                    style:
                                        TextStyle(fontFamily: 'Boogaloo'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isDark
                                ? Colors.black.withOpacity(0.6)
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  IconData(logro['icono'],
                                      fontFamily: 'MaterialIcons'),
                                  color: logro['color'],
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                logro['titulo'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  logro['fecha'] != null
                                      ? "${logro['fecha'].day}/${logro['fecha'].month}/${logro['fecha'].year}"
                                      : "Sin fecha",
                                  style: TextStyle(
                                    fontFamily: 'Boogaloo',
                                    fontSize: 14,
                                    color: _isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Botón flotante
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor:
                  _isDark ? Colors.blueAccent : Colors.white,
              shape: const CircleBorder(),
              child: Icon(Icons.add,
                  color: _isDark ? Colors.white : Colors.black),
              onPressed: () => _showAddLogroDialog(),
            ),
          ),

          // 🔹 Felicidades animación
          if (showCongrats)
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isDark ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset('assets/animations/felicidades.json',
                          width: 200, height: 200),
                      const SizedBox(height: 16),
                      Text(
                        "🎉 FELICIDADES 🎉",
                        style: TextStyle(
                          fontFamily: 'Boogaloo',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color:
                              _isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddLogroDialog() {
    final TextEditingController controller = TextEditingController();
    IconData selectedIcon = Icons.star;
    Color selectedColor = Colors.amber;
    DateTime selectedDate = DateTime.now();

    final List<IconData> iconOptions = [
      Icons.star,
      Icons.favorite,
      Icons.emoji_events,
      Icons.check_circle,
      Icons.flash_on,
      Icons.cake,
      Icons.shield,
      Icons.book,
      Icons.school,
      Icons.sports_soccer,
      Icons.music_note,
      Icons.travel_explore,
      Icons.lightbulb,
      Icons.bug_report,
      Icons.brush,
      Icons.camera_alt,
      Icons.cloud,
      Icons.spa,
      Icons.work,
      Icons.sentiment_satisfied,
    ];

    final List<Color> colorOptions = [
      Colors.amber,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.lime,
      Colors.indigo,
      Colors.brown,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.yellow,
      Colors.grey,
      const Color.fromARGB(255, 203, 232, 245),
      const Color.fromARGB(255, 200, 218, 179),
      const Color.fromARGB(255, 241, 176, 201),
      Colors.blueGrey,
      Colors.black,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            backgroundColor: _isDark ? Colors.black : Colors.white,
            title: Text(
              "Ingresa tu nuevo logro",
              style: TextStyle(
                  fontFamily: 'Boogaloo',
                  color: _isDark ? Colors.white : Colors.black),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                        labelText: "Título del logro",
                        labelStyle: TextStyle(
                            color: _isDark ? Colors.white70 : Colors.black)),
                    style: TextStyle(
                        fontFamily: 'Boogaloo',
                        color: _isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 12),

                  // Selector de iconos
                  Wrap(
                    spacing: 8,
                    children: iconOptions.map((icon) {
                      return IconButton(
                        icon: Icon(icon,
                            color: selectedIcon == icon
                                ? selectedColor
                                : Colors.grey),
                        onPressed: () =>
                            setStateDialog(() => selectedIcon = icon),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 8),
                  // Selector de colores
                  Wrap(
                    spacing: 8,
                    children: colorOptions.map((color) {
                      return GestureDetector(
                        onTap: () =>
                            setStateDialog(() => selectedColor = color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: selectedColor == color ? 18 : 14,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Selector de fecha
                  Row(
                    children: [
                      Text(
                        "Fecha: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: TextStyle(
                            fontFamily: 'Boogaloo',
                            color:
                                _isDark ? Colors.white70 : Colors.black),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today,
                            color:
                                _isDark ? Colors.white : Colors.black),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() => selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(
                      fontFamily: 'Boogaloo', color: Colors.blueAccent),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    addLogro(controller.text, selectedIcon, selectedColor,
                        selectedDate);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text(
                  "Agregar logro",
                  style: TextStyle(fontFamily: 'Boogaloo'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
