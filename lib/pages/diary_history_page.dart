//HARDY Y JOSUE ESTA PAGINA NO LA MODIFICARAN SE QUEDA COMO ESTA

// lib/pages/diary_history_page.dart
// Estas líneas (ignore_for_file) desactivan algunos avisos del analizador de Dart,ya que no afecta su funcionamiento la linea de abajo es una de esas 
// ignore_for_file: deprecated_member_use, unused_local_variable, use_build_context_synchronously


// las cosas que en comentarios diga DISEÑO no tocarlas ni borrarlas 
// las cosas de logica pueden modificarlas dependiedo en caso,pero de igual forma verifiquen si es comveniente 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

// Pantalla principal del historial del diario
// Es StatefulWidget porque el historial depende de los datos en Firebase (que cambian en tiempo real)
class DiaryHistoryPage extends StatefulWidget {
  final bool isDarkTheme; // Tema claro/oscuro
  const DiaryHistoryPage({super.key, this.isDarkTheme = false});

  @override
  State<DiaryHistoryPage> createState() => _DiaryHistoryPageState();
}

class _DiaryHistoryPageState extends State<DiaryHistoryPage> {
  // Getter para saber si el tema es oscuro
  bool get isDarkTheme => widget.isDarkTheme;

  // Esta función construye la ruta de las imágenes
  // Se asegura de no duplicar la carpeta "assets/images/"
  String buildImagePath(String? name) {
    if (name == null || name.isEmpty) return "assets/images/default.png";
    if (name.startsWith("assets/images/")) return name;
    return "assets/images/$name";
  }

  @override
  Widget build(BuildContext context) {
    // Se obtiene el usuario autenticado en Firebase
    final user = FirebaseAuth.instance.currentUser;

    // Fondos diferentes según el tema
    final bgLight = "assets/images/history_bg_light.jpg"; 
    final bgDark = "assets/images/history_bg_dark.jpg"; 

    return Scaffold(
      body: Stack(
        children: [
          // --- DISEÑO: Fondo de pantalla ---
          Positioned.fill(
            child: Image.asset(
              isDarkTheme ? bgDark : bgLight,
              fit: BoxFit.cover,
            ),
          ),

          // --- DISEÑO: Animación Lottie arriba ---
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 150,
              child: Lottie.asset("assets/animations/profile.json"),
            ),
          ),

          // --- LÓGICA: si no hay usuario, mostrar aviso ---
          if (user == null)
            const Center(
              child: Text("Debes iniciar sesión para ver tu historial"),
            )
          else
            // --- LÓGICA + DISEÑO: lista de notas del diario ---
            Padding(
              padding: const EdgeInsets.only(top: 180.0),
              child: StreamBuilder<QuerySnapshot>(
                // Se conecta a Firebase Firestore
                stream: FirebaseFirestore.instance
                    .collection("usuarios")
                    .doc(user.uid)
                    .collection("notas")
                    .orderBy("fecha", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  // --- LÓGICA: control de errores ---
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("❌ Error al cargar el historial"));
                  }
                  // --- LÓGICA: mostrar indicador mientras carga ---
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Se guardan los documentos de la colección
                  final docs = snapshot.data!.docs;

                  // --- LÓGICA: si no hay notas ---
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay entradas todavía",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  // --- DISEÑO + LÓGICA: Lista de notas ---
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      // Datos de cada nota
                      final data =
                          docs[index].data() as Map<String, dynamic>? ?? {};
                      final docId = docs[index].id;
                      final texto = data["texto"] ?? "";
                      final fecha = (data["fecha"] as Timestamp?)?.toDate();
                      final emocion = (data["emocion"] as String?) ?? "";
                      final sentimientos =
                          (data["sentimientos"] as List?)?.cast<String>() ?? [];
                      final background = data["background"];

                      // Cada nota se representa como un "card" (contenedor con estilo)
                      return GestureDetector(
                        // --- LÓGICA: eliminar con pulsación larga ---
                        onLongPress: () async {
                          final eliminar = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor:
                                  isDarkTheme ? Colors.grey[900] : Colors.white,
                              title: const Text("Eliminar nota"),
                              content: const Text("¿Deseas eliminar esta nota?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text("Sí"),
                                ),
                              ],
                            ),
                          );

                          if (eliminar == true) {
                            // Aquí se borra la nota en Firebase
                            await FirebaseFirestore.instance
                                .collection("usuarios")
                                .doc(user.uid)
                                .collection("notas")
                                .doc(docId)
                                .delete();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Nota eliminada")),
                              );
                            }
                          }
                        },

                        // --- LÓGICA: abrir detalle de la nota ---
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DiaryDetailPage(
                                entry: data,
                                isDarkTheme: isDarkTheme,
                              ),
                            ),
                          );
                        },

                        // --- DISEÑO: tarjeta que representa cada nota ---
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isDarkTheme
                                ? Colors.black.withOpacity(0.6)
                                : Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Fecha
                                if (fecha != null)
                                  Text(
                                    "${fecha.day}/${fecha.month}/${fecha.year}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkTheme
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                const SizedBox(height: 8),

                                // Emoción principal (imagen)
                                if (emocion.isNotEmpty)
                                  Image.asset(
                                    buildImagePath(emocion),
                                    height: 50,
                                  ),
                                const SizedBox(height: 8),

                                // Texto de la nota
                                Text(
                                  texto.isNotEmpty
                                      ? texto
                                      : "Sin texto en esta nota",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Sentimientos adicionales (varias imágenes)
                                if (sentimientos.isNotEmpty)
                                  Wrap(
                                    spacing: 8,
                                    children: sentimientos
                                        .map(
                                          (s) => Image.asset(
                                            buildImagePath(s),
                                            height: 40,
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Página de detalle de una nota concreta
class DiaryDetailPage extends StatelessWidget {
  final Map<String, dynamic> entry; // Datos de la nota
  final bool isDarkTheme;

  const DiaryDetailPage({
    super.key,
    required this.entry,
    required this.isDarkTheme,
  });

  // Construye la ruta de las imágenes
  String buildImagePath(String? name) {
    if (name == null || name.isEmpty) return "assets/images/default.png";
    if (name.startsWith("assets/images/")) return name;
    return "assets/images/$name";
  }

  @override
  Widget build(BuildContext context) {
    // Datos de la nota recibida
    final texto = entry["texto"] ?? "";
    final fecha = (entry["fecha"] as Timestamp?)?.toDate();
    final emocion = (entry["emocion"] as String?) ?? "";
    final sentimientos = (entry["sentimientos"] as List?)?.cast<String>() ?? [];
    final postIts = (entry["postIts"] as List?)?.cast<Map>() ?? [];
    final stickers = (entry["stickers"] as List?)?.cast<Map>() ?? [];
    final background = entry["background"];

    return Scaffold(
      body: Stack(
        children: [
          // Fondo de la nota si tiene uno guardado
          if (background != null)
            Positioned.fill(
              child: Image.asset(
                buildImagePath(background),
                fit: BoxFit.cover,
              ),
            ),

          // Animación superior
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 150,
              child: Lottie.asset("assets/animations/profile.json"),
            ),
          ),

          // Contenido principal de la nota
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 180, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? Colors.black.withOpacity(0.6)
                    : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha de la nota
                  if (fecha != null)
                    Text(
                      "${fecha.day}/${fecha.month}/${fecha.year}",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? Colors.white70 : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Emoción principal
                  if (emocion.isNotEmpty)
                    Image.asset(
                      buildImagePath(emocion),
                      height: 60,
                    ),
                  const SizedBox(height: 12),

                  // Texto principal
                  Text(
                    texto,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista de sentimientos
                  if (sentimientos.isNotEmpty) ...[
                    const Text(
                      "Sentimientos:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: sentimientos
                          .map(
                            (s) => Image.asset(
                              buildImagePath(s),
                              height: 40,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Post-Its asociados a la nota
                  if (postIts.isNotEmpty) ...[
                    const Text(
                      "Post-Its:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: postIts
                          .map(
                            (p) => Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 8),
                              color: Colors.yellow[200],
                              child: Text(p["text"] ?? "Post-it"),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stickers añadidos
                  if (stickers.isNotEmpty) ...[
                    const Text(
                      "Stickers:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: stickers
                          .map(
                            (s) => Image.asset(
                              buildImagePath(s["path"]),
                              height: 50,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
