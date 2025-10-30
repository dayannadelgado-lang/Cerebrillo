// ignore: file_names
// ignore: file_names
// ignore: file_names
//ignore 
// ignore_for_file: file_names, duplicate_ignore, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  Color _selectedColor = Colors.purpleAccent;
  Gradient _selectedGradient = LinearGradient(colors: [Colors.pink, Colors.purple]);
  bool _showColorPicker = false;

  bool _awaitingReason = false;
  bool _awaitingCategory = false;
  String _currentEmotion = "";

  late AnimationController _lottieController;

  // Opciones de colores predefinidas
  final List<Color> predefinedColors = [
    Colors.red, Colors.blue, Colors.green, // normales
    Colors.pink[200]!, Colors.lightBlue[200]!, // pasteles
  ];

  final List<Gradient> predefinedGradients = [
    LinearGradient(colors: [Colors.red, Colors.orange]), // normal
    LinearGradient(colors: [Colors.blue, Colors.green]), // normal
    LinearGradient(colors: [Colors.purple, Colors.pink]), // normal
    LinearGradient(colors: [Colors.pink[200]!, Colors.purple[200]!]), // pastel
    LinearGradient(colors: [Colors.lightBlue[200]!, Colors.green[200]!]), // pastel
  ];

  final Map<String, List<String>> emocionesRespuestas = {
    "cansada": [
      "Uf, entiendo que estés cansada. A veces todo se acumula y necesitamos un respiro.",
      "Seguro que has trabajado duro hoy. Tómate un momento para ti.",
      "Respira hondo, deja que la tensión se vaya poco a poco.",
      "A veces descansar un rato hace maravillas, mereces ese tiempo.",
      "Sé que los días largos agotan, pero pronto tendrás un momento de calma."
    ],
    "triste": [
      "Vaya, siento que te sientas así. ¿Quieres contarme qué pasó?",
      "Está bien sentirse mal, todos tenemos días difíciles.",
      "No estás sola, si quieres puedes hablarme de ello.",
      "A veces expresar lo que sentimos ayuda a aliviar un poco la tristeza.",
      "Sé que es duro ahora, pero esto también pasará."
    ],
    "enojada": [
      "Entiendo, hay cosas que frustran mucho. Cuéntame si quieres.",
      "Respira hondo, a veces dejar salir un poco de enojo ayuda.",
      "No dejes que esto te arruine el día, puedes manejarlo.",
      "Sé que molesta, tómate un momento para calmarte.",
      "Es normal sentir enojo, pero pronto se sentirá mejor."
    ],
    "estresada": [
      "Uf, el estrés es intenso. Haz una pausa si puedes.",
      "A veces un poco de música o respirar profundo ayuda a calmarse.",
      "Todo se puede resolver paso a paso, respira hondo.",
      "No dejes que el estrés te domine, intenta relajarte un momento.",
      "Tú puedes con esto, un descanso corto puede hacer maravillas."
    ],
    "bien": [
      "Me alegra saber que estás bien. ¿Por qué te sientes así hoy?",
      "¡Genial! Cuéntame, ¿qué ha hecho que te sientas bien?",
      "Qué gusto escuchar eso. ¿Quieres contarme la razón?",
      "Me alegra que estés bien, ¿qué ha pasado para que sea así?",
      "Eso suena muy positivo, ¿por qué te sientes así hoy?"
    ],
    "excelente": [
      "¡Wow! Qué alegría que estés excelente. ¿Qué pasó para que te sientas así?",
      "Genial escuchar eso, cuéntame más sobre por qué estás tan bien.",
      "¡Eso es increíble! ¿Qué hizo tu día tan excelente?",
      "Me encanta tu energía, ¿qué ha hecho que te sientas así?",
      "Qué orgullo escucharlo, cuéntame un poco sobre eso."
    ]
  };

  final Map<String, String> cuentos = {
    "fantasía": "En lo profundo del bosque de Lúminis, los árboles hablaban entre sí en un lenguaje que solo los animales escuchaban. Una noche, Lyra, una niña con ojos como la luna, siguió un rastro de luces danzantes hasta un lago que reflejaba un cielo estrellado diferente al suyo. Allí encontró un pequeño dragón atrapado en redes de sombras. Con un susurro, Lyra le enseñó a hablar con las estrellas y, al hacerlo, el dragón se liberó y le regaló una pluma que brillaba con todos los colores del amanecer. Desde entonces, cada vez que Lyra la tocaba, podía escuchar los secretos del bosque y las estrellas, como si el universo entero le hablara al oído",
    "terror": "Una sombra recorría el pasillo cada noche. Nadie la veía a la luz del día, pero los ruidos mantenían a todos despiertos...",
    "aventura": "Un joven navegante emprendió un viaje hacia la isla desconocida, enfrentando tormentas y criaturas marinas...",
    "amor": "Cada mañana, Mateo veía a Clara desde su ventana del café. Ella nunca lo miraba, siempre absorta en un cuaderno viejo. Un día, una hoja se le escapó de sus manos y cayó frente a él. Al recogerla, leyó: “A veces, el corazón ve lo que los ojos ignoran.” Sonrió y decidió acercarse. Sin palabras, le ofreció un café y una sonrisa que duró más que cualquier texto escrito. Desde aquel instante, no necesitaron más que miradas; sus corazones ya hablaban el mismo idioma.",
    "ciencia ficción": "En un futuro donde los humanos vivían en ciudades flotantes, una científica descubrió un portal hacia un universo paralelo...",
    "infantil": "Un conejito curioso decidió explorar el bosque. Conoció a amigos como la tortuga sabia, el búho bromista y la ardilla rápida...",
    "inspirador": "Una joven soñadora enfrentaba cada día con dudas, pero nunca se rindió. Cada pequeño paso que daba la acercaba a sus metas..."
  };

  @override
  void initState() {
    super.initState();
    _lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _lottieController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomColor() async {
    Color tempColor = _selectedColor;
    Color tempColor2 = tempColor;
    bool isGradient = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona color o degradado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text("Degradado"),
                Switch(
                  value: isGradient,
                  onChanged: (val) => setState(() => isGradient = val),
                ),
              ],
            ),
            ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (c) => tempColor = c,
              showLabel: true,
              pickerAreaHeightPercent: 0.7,
            ),
            if (isGradient)
              ColorPicker(
                pickerColor: tempColor2,
                onColorChanged: (c) => tempColor2 = c,
                showLabel: true,
                pickerAreaHeightPercent: 0.7,
              ),
            const SizedBox(height: 10),
            const Text("Opciones rápidas:"),
            Wrap(
              spacing: 6,
              children: [
                for (var c in predefinedColors)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = c;
                        _selectedGradient = LinearGradient(colors: [c.withOpacity(0.7), c]);
                        _showColorPicker = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(width: 30, height: 30, color: c),
                  ),
                for (var g in predefinedGradients)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGradient = g;
                        _showColorPicker = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: g,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() {
                if (isGradient) {
                  _selectedGradient = LinearGradient(colors: [tempColor, tempColor2]);
                } else {
                  _selectedColor = tempColor;
                  _selectedGradient = LinearGradient(colors: [tempColor.withOpacity(0.7), tempColor]);
                }
                _showColorPicker = false;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<String> _generateBotResponse(String userMessage) async {
    String msg = userMessage.toLowerCase().trim();
    final Random rng = Random();

    final saludos = ["hola", "hey", "buenas", "buen día", "buenas tardes", "buenas noches"];
    for (var saludo in saludos) {
      if (msg.contains(saludo)) {
        return [
          "¡Hola! 😊 ¿Cómo te encuentras hoy?",
          "¡Hey! Qué gusto verte, ¿cómo va tu día?",
          "¡Hola, hola! 🌸 ¿Qué tal te sientes?",
          "¡Buenas! Cuéntame, ¿cómo estás?",
          "¡Qué alegría verte por aquí! 💫 ¿Cómo te va hoy?"
        ][rng.nextInt(5)];
      }
    }

    if (msg == "ok" || msg == "okey") return "¿Deseas hablar de algo más?";

    if (_awaitingCategory) {
      _awaitingCategory = false;
      final categorias = {
        "1": "fantasía",
        "2": "misterio",
        "3": "terror",
        "4": "aventura",
        "5": "amor",
        "6": "ciencia ficción",
        "7": "infantil",
        "8": "inspirador",
        "fantasía": "fantasía",
        "misterio": "misterio",
        "terror": "terror",
        "aventura": "aventura",
        "amor": "amor",
        "ciencia ficción": "ciencia ficción",
        "infantil": "infantil",
        "inspirador": "inspirador"
      };
      String categoria = categorias[msg] ?? "fantasía";
      return cuentos[categoria]!;
    }

    if (msg.contains("cuento")) {
      _awaitingCategory = true;
      return "¡Perfecto! 😊 ¿Qué tipo de cuento te gustaría leer? Puedes escribir el número o el nombre:\n\n"
          "1. Fantasía 🌌\n2. Misterio 🔍\n3. Terror 👻\n4. Aventura 🗺️\n5. Amor ❤️\n6. Ciencia ficción 🤖\n7. Infantil 🐰\n8. Inspirador 🌟";
    }

    if (_awaitingReason && _currentEmotion.isNotEmpty) {
      _awaitingReason = false;
      return "Me alegra que me lo compartas. No estás sola en esto, en las buenas y en las malas estaré 💕";
    }

    for (String emo in emocionesRespuestas.keys) {
      if (msg.contains(emo)) {
        _awaitingReason = true;
        _currentEmotion = emo;
        return emocionesRespuestas[emo]![rng.nextInt(emocionesRespuestas[emo]!.length)];
      }
    }

    RegExp op = RegExp(r"(\d+(?:\.\d+)?)\s*([\+\-\*\/])\s*(\d+(?:\.\d+)?)");
    Match? m = op.firstMatch(msg);
    if (m != null) {
      double a = double.parse(m.group(1)!);
      double b = double.parse(m.group(3)!);
      switch (m.group(2)) {
        case '+':
          return "El resultado de $a + $b es ${(a + b).toStringAsFixed(2)} ✅";
        case '-':
          return "El resultado de $a - $b es ${(a - b).toStringAsFixed(2)} ✏️";
        case '*':
          return "El resultado de $a × $b es ${(a * b).toStringAsFixed(2)} 💪";
        case '/':
          if (b == 0) return "No se puede dividir entre 0 😅";
          return "El resultado de $a ÷ $b es ${(a / b).toStringAsFixed(2)} 💡";
      }
    }

    return [
      "Interesante 🤔, cuéntame un poco más.",
      "Hmm, suena profundo. ¿Quieres que hablemos más de eso?",
      "Eso suena curioso 😄, cuéntame más detalles.",
      "Guau, nunca había pensado en eso así.",
      "Cuéntame más sobre eso, me interesa mucho escucharte."
    ][rng.nextInt(5)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(child: Image.asset('assets/images/fondologro1.jpg', fit: BoxFit.cover)),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Lottie.asset('assets/animations/ini1.json', width: 120, height: 120, repeat: true),
                Lottie.asset('assets/animations/meditacion.json', width: 70, height: 70, repeat: true),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity((0.05 + (_messages.length * 0.03)).clamp(0.05, 0.35)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 200),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Align(
                          alignment:
                              msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: msg.color?.withOpacity(0.9),
                              gradient: msg.gradient,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: const Offset(1, 2))
                              ],
                            ),
                            child: Text(
                              msg.text,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: "Montserrat"),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24)),
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                  hintText: "Escribe un mensaje...",
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                gradient: _selectedGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: _selectedColor.withOpacity(0.7),
                                      blurRadius: 8,
                                      spreadRadius: 1)
                                ]),
                            child: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: GestureDetector(
              onTap: () => setState(() => _showColorPicker = !_showColorPicker),
              child: const Icon(Icons.palette_rounded,
                  color: Colors.white, size: 36),
            ),
          ),
          if (_showColorPicker)
            Positioned(
              bottom: 130,
              right: 10,
              child: GestureDetector(
                onTap: _pickCustomColor,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text("Personalizar color"),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
          text: text, isUser: true, gradient: _selectedGradient, color: null));
    });

    _controller.clear();

    await Future.delayed(const Duration(milliseconds: 150));

    final reply = await _generateBotResponse(text);

    setState(() {
      _messages.add(_ChatMessage(
          text: reply,
          isUser: false,
          color: Colors.white.withOpacity(0.85),
          gradient: null));
    });

    await Future.delayed(const Duration(milliseconds: 150));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final Color? color;
  final Gradient? gradient;

  _ChatMessage({required this.text, required this.isUser, this.color, this.gradient});
}
