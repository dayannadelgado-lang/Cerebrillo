//HARDY Y JOSUE ESTA PAGINA NO LA MODIFICARAN SE QUEDA COMO ESTA


// lib/pages/note_editor_page.dart 
// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_import, unnecessary_to_list_in_spreads, strict_top_level_inference, unused_field, unused_element, unused_local_variable, prefer_final_fields

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:lottie/lottie.dart';
import 'diary_history_page.dart'; // <- Importamos la página de historial

class NoteEditorPage extends StatefulWidget {
  final String? selectedEmotion;
  final List<String>? selectedFeelings;
  final bool isDarkTheme;

  const NoteEditorPage({super.key, this.selectedEmotion, this.selectedFeelings, required this.isDarkTheme});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();

  // Fondos de cuaderno
  final List<String> backgrounds =
      List.generate(25, (i) => "assets/images/cuaderno${i + 1}.png");
  int selectedBackground = 0;

  // Post-its y stickers
  List<Map<String, dynamic>> postIts = [];
  List<Map<String, dynamic>> addedStickers = [];
  final List<String> postItImages =
      List.generate(10, (i) => "assets/images/postit${i + 1}.png");
  final List<String> stickerImages =
      List.generate(10, (i) => "assets/images/sticker${i + 1}.png");

  // Fuente y estilo
  String selectedFont = "Boogaloo";
  double selectedFontSize = 20;
  Color selectedFontColor = Colors.black;
  FontStyle selectedFontStyle = FontStyle.normal;
  FontWeight selectedFontWeight = FontWeight.normal;

  // Carruseles de niveles por emoción
  final Map<String, List<String>> emotionCarousels = {
    "felicidad": [
      "assets/images/felicidad1.png",
      "assets/images/felicidad2.png",
      "assets/images/felicidad3.png",
      "assets/images/felicidad4.png",
      "assets/images/felicidad5.png",
    ],
    "tristeza": [
      "assets/images/tristeza1.png",
      "assets/images/tristeza2.png",
      "assets/images/tristeza3.png",
      "assets/images/tristeza4.png",
      "assets/images/tristeza5.png",
    ],
    "asco": [
      "assets/images/asco1.png",
      "assets/images/asco2.png",
      "assets/images/asco3.png",
      "assets/images/asco4.png",
      "assets/images/asco5.png",
    ],
    "miedo": [
      "assets/images/miedo1.png",
      "assets/images/miedo2.png",
      "assets/images/miedo3.png",
      "assets/images/miedo4.png",
      "assets/images/miedo5.png",
    ],
    "enojo": [
      "assets/images/enojo1.png",
      "assets/images/enojo2.png",
      "assets/images/enojo3.png",
      "assets/images/enojo4.png",
      "assets/images/enojo5.png",
    ],
    "sorpresa": [
      "assets/images/sorpresa1.png",
      "assets/images/sorpresa2.png",
      "assets/images/sorpresa3.png",
      "assets/images/sorpresa4.png",
      "assets/images/sorpresa5.png",
    ],
  };

  // Frases motivacionales
  final Map<String, String> motivationalImages = {
    "alegria": "assets/images/frase_alegria.jpg",
    "depresion": "assets/images/frase_depresion.jpg",
    "ansiedad": "assets/images/frase_ansiedad.jpg",
    "distraido": "assets/images/frase_distraido.jpg",
    "furia": "assets/images/frase_furia.jpg",
    "insomnio": "assets/images/frase_insomnio.jpg",
  };

  String? selectedLevel;
  String? mainEmotionKey;

  // Animación holográfica
  late AnimationController _holoController;
  late Animation<double> _holoAnimation;

  // Carrusel (tipo actualizado)
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentCarouselIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    mainEmotionKey = _keyFromPath(widget.selectedEmotion);
    _holoController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _holoAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(_holoController);

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_carouselController.ready && mainEmotionKey != null) {
        final images = emotionCarousels[mainEmotionKey!]!;
        int nextIndex = (_currentCarouselIndex + 1) % images.length;
        _carouselController.animateToPage(nextIndex);
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _holoController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  String? _keyFromPath(String? path) {
    if (path == null) return null;
    final fileName = path.split('/').last.split('.').first.toLowerCase();
    final Map<String, String> mapDiaryToNote = {
      'asco': 'asco',
      'enojo': 'enojo',
      'felicidad': 'felicidad',
      'miedo': 'miedo',
      'sorpresa': 'sorpresa',
      'tristeza': 'tristeza',
      'alegria': 'alegria',
      'distraido': 'distraido',
      'ansiedad': 'ansiedad',
      'insomnio': 'insomnio',
      'depresion': 'depresion',
      'furia': 'furia',
    };
    return mapDiaryToNote[fileName];
  }

  // ---- GUARDAR NOTA ----
  Future<void> _saveNote() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(user.uid)
            .collection("notas")
            .add({
          "texto": _noteController.text,
          "fecha": DateTime.now(),
          "background": backgrounds[selectedBackground],
          "postIts": postIts,
          "stickers": addedStickers,
          "font": selectedFont,
          "fontSize": selectedFontSize,
          "fontColor": selectedFontColor.value,
          "fontStyle": selectedFontStyle == FontStyle.italic ? "italic" : "normal",
          "fontWeight": selectedFontWeight == FontWeight.bold ? "bold" : "normal",
          "emocion": widget.selectedEmotion,
          "nivel": selectedLevel,
          "sentimientos": widget.selectedFeelings,
          "frase": widget.selectedFeelings != null && widget.selectedFeelings!.isNotEmpty
              ? motivationalImages[_keyFromPath(widget.selectedFeelings!.first) ?? ""]
              : null,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Nota guardada en tu diario")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error guardando nota: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al guardar nota")),
      );
    }
  }

  // ---- MENÚ ----
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: widget.isDarkTheme ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Menú",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                const Divider(color: Colors.grey),
                _menuSection("Cuadernos", backgrounds, (index) {
                  setState(() => selectedBackground = index);
                  Navigator.pop(context);
                }),
                _menuSection("Post-its", postItImages, (index) {
                  _addPostItWithImage(postItImages[index]);
                  Navigator.pop(context);
                }),
                _menuSection("Stickers", stickerImages, (index) {
                  _addStickerWithImage(stickerImages[index]);
                  Navigator.pop(context);
                }),
                const SizedBox(height: 10),
                _fontSettings(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _saveNote,
                      icon: const Icon(Icons.save),
                      label: const Text("Guardar Nota"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DiaryHistoryPage()),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text("Historial"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuSection(String title, List<String> items, Function(int) onSelect) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: widget.isDarkTheme ? Colors.white : Colors.black,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
        ),
      ),
      child: ExpansionTile(
        title: Text(title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: widget.isDarkTheme ? Colors.white : Colors.black,
            )),
        children: [
          SizedBox(
            height: 100,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, mainAxisSpacing: 8),
              itemCount: items.length,
              itemBuilder: (_, index) => GestureDetector(
                onTap: () => onSelect(index),
                child: Image.asset(items[index]),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _fontSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tipografía",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: widget.isDarkTheme ? Colors.white : Colors.black,
            )),
        const SizedBox(height: 6),
        DropdownButton<String>(
          dropdownColor: widget.isDarkTheme ? Colors.grey[900] : Colors.white,
          value: selectedFont,
          items: [
            "LuckiestGuy",
            "JustAnotherHand",
            "Boogaloo",
            "Chewy",
            "ConcertOne",
            "Montserrat",
            "Caprasimo",
            "AbrilFatface",
            "SpicyRice",
            "Bentham",
          ]
              .map((f) =>
                  DropdownMenuItem(value: f, child: Text(f, style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black))))
              .toList(),
          onChanged: (v) => setState(() => selectedFont = v!),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text("Color:"),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: widget.isDarkTheme ? Colors.grey[900] : Colors.white,
                    title: const Text("Selecciona un color", style: TextStyle(color: Colors.black)),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: selectedFontColor,
                        onColorChanged: (color) =>
                            setState(() => selectedFontColor = color),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar"))
                    ],
                  ),
                );
              },
              child: Container(
                width: 24,
                height: 24,
                color: selectedFontColor,
              ),
            ),
            const SizedBox(width: 16),
            const Text("Tamaño:"),
            Slider(
              value: selectedFontSize,
              min: 10,
              max: 36,
              divisions: 13,
              label: selectedFontSize.round().toString(),
              onChanged: (v) => setState(() => selectedFontSize = v),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildMovableItem(Map<String, dynamic> item, String asset) {
    return Positioned(
      left: item["dx"],
      top: item["dy"],
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            item["dx"] += details.focalPointDelta.dx;
            item["dy"] += details.focalPointDelta.dy;
            double newWidth = item["width"] * details.scale;
            double newHeight = item["height"] * details.scale;
            item["width"] = newWidth.clamp(50.0, 200.0);
            item["height"] = newHeight.clamp(50.0, 200.0);
          });
        },
        onLongPress: () {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    backgroundColor: widget.isDarkTheme ? Colors.grey[900] : Colors.white,
                    title: const Text("Eliminar", style: TextStyle(color: Colors.black)),
                    content: const Text("¿Deseas eliminar este elemento?", style: TextStyle(color: Colors.black)),
                    actions: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              postIts.remove(item);
                              addedStickers.remove(item);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Sí")),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("No"))
                    ],
                  ));
        },
        child: Transform.rotate(
          angle: item["rotation"],
          child: Image.asset(asset,
              width: item["width"], height: item["height"]),
        ),
      ),
    );
  }

  void _addPostItWithImage(String img) {
    setState(() {
      postIts.add({
        "id": UniqueKey().toString(),
        "dx": 40.0 + Random().nextInt(120),
        "dy": 60.0 + Random().nextInt(120),
        "width": 100.0,
        "height": 70.0,
        "rotation": 0.0,
      });
    });
  }

  void _addStickerWithImage(String img) {
    setState(() {
      addedStickers.add({
        "id": UniqueKey().toString(),
        "dx": 40.0 + Random().nextInt(120),
        "dy": 80.0 + Random().nextInt(120),
        "width": 70.0,
        "height": 70.0,
        "rotation": 0.0,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? firstFeelingKey = widget.selectedFeelings != null &&
            widget.selectedFeelings!.isNotEmpty
        ? _keyFromPath(widget.selectedFeelings!.first)
        : null;

    final List<String>? levelImages =
        mainEmotionKey != null ? emotionCarousels[mainEmotionKey!] : null;

    final String? phraseImage =
        firstFeelingKey != null ? motivationalImages[firstFeelingKey] : null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: widget.isDarkTheme
                ? Image.asset(
                    "assets/images/notafondo_dark.jpg",
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/images/notafondo2.jpg",
                    fit: BoxFit.cover,
                  ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 45.0, bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: Lottie.asset(
                          "assets/animations/ini1.json",
                          fit: BoxFit.contain,
                        ),
                      ),
                      Image.asset(
                        "assets/images/escribir.png",
                        width: 120,
                        height: 120,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        "DIARIO PERSONAL",
                        style: TextStyle(
                          fontFamily: "ConcertOne",
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2.5
                            ..color = widget.isDarkTheme ? Colors.black : Colors.black,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _holoAnimation,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                colors: widget.isDarkTheme
                                    ? const [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 23, 0, 125), Color.fromARGB(255, 0, 22, 128), Color.fromARGB(255, 255, 255, 255)]
                                    : const [
                                        Colors.white,
                                        Color.fromARGB(255, 209, 169, 211),
                                        Color.fromARGB(255, 209, 169, 211),
                                        Colors.white,
                                      ],
                                begin: Alignment(_holoAnimation.value, 0),
                                end: Alignment(-_holoAnimation.value, 0),
                              ).createShader(rect);
                            },
                            child: Text(
                              "DIARIO PERSONAL",
                              style: TextStyle(
                                fontFamily: "ConcertOne",
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: widget.isDarkTheme ? Colors.white : Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        backgrounds[selectedBackground],
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width * 0.75,
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                          child: TextField(
                            controller: _noteController,
                            maxLines: null,
                            style: TextStyle(
                              fontFamily: selectedFont,
                              fontSize: selectedFontSize,
                              color: selectedFontColor,
                              fontStyle: selectedFontStyle,
                              fontWeight: selectedFontWeight,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Querido diario...",
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      ...postIts.map((item) => _buildMovableItem(item, postItImages[0])).toList(),
                      ...addedStickers.map((item) => _buildMovableItem(item, stickerImages[0])).toList(),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (levelImages != null) ...[
                    Text(
                      "Selecciona el nivel de tu emoción",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    CarouselSlider.builder(
                      itemCount: levelImages.length,
                      itemBuilder: (context, index, realIndex) {
                        double scale = index == _currentCarouselIndex ? 1.0 : 0.7;
                        return Transform.scale(
                          scale: scale,
                          child: GestureDetector(
                            onTap: () => setState(() => selectedLevel = levelImages[index]),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3.0),
                              decoration: BoxDecoration(
                                border: selectedLevel == levelImages[index]
                                    ? Border.all(
                                        color: const Color.fromARGB(255, 255, 154, 216),
                                        width: 2)
                                    : null,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Image.asset(
                                levelImages[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 70,
                        viewportFraction: 0.33,
                        enlargeCenterPage: true,
                        enlargeStrategy: CenterPageEnlargeStrategy.scale,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentCarouselIndex = index;
                          });
                        },
                      ),
                      carouselController: _carouselController,
                    ),
                    const SizedBox(height: 5),
                  ],
                  if (phraseImage != null)
                    Image.asset(
                      phraseImage,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.95,
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: MediaQuery.of(context).size.height * 0.45,
            child: Draggable(
              feedback: _menuTab(),
              childWhenDragging: const SizedBox(),
              child: GestureDetector(
                onTap: _showMenu,
                child: _menuTab(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTab() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: widget.isDarkTheme ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
          ]),
      child: Text(
        "Menu",
        style: TextStyle(
          fontSize: 12,
          color: widget.isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
