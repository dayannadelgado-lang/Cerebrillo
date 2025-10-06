//HARDY Y JOSUE ESTA PAGINA NO LA MODIFICARAN SE QUEDA COMO ESTA



// lib/pages/meditacion_page.dart
// ignore_for_file: depend_on_referenced_packages, unused_element, deprecated_member_use, strict_top_level_inference, avoid_print

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';
import 'home_page.dart';

class MeditacionPage extends StatefulWidget {
  const MeditacionPage({super.key});

  @override
  MeditacionPageState createState() => MeditacionPageState();
}

class MeditacionPageState extends State<MeditacionPage> {
  late final AudioPlayer _audioPlayer;
  int dia = DateTime.now().weekday;
  bool _isDark = false;

  Map<int, String> tipsSemana = {
    1: "RESPIRANDO EN EL PRESENTE",
    2: "SILENCIO INTERIOR",
    3: "GRATITUD DIARIA",
    4: "SOLTAR Y DEJAR IR",
    5: "VISUALIZANDO LA PAZ",
    6: "CONEXION CON UNO MISMO",
    7: "RENOVACION Y ENERGIA",
  };

  Map<int, String> audiosSemana = {
    1: 'assets/sounds/meditacion1.mp3',
    2: 'assets/sounds/meditacion2.mp3',
    3: 'assets/sounds/meditacion3.mp3',
    4: 'assets/sounds/meditacion4.mp3',
    5: 'assets/sounds/meditacion5.mp3',
    6: 'assets/sounds/meditacion6.mp3',
    7: 'assets/sounds/meditacion7.mp3',
  };

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _initAudio();

    // Escucha cambios de posición y duración
    _audioPlayer.positionStream.listen((p) {
      setState(() => position = p);
    });
    _audioPlayer.durationStream.listen((d) {
      if (d != null) setState(() => duration = d);
    });
    _audioPlayer.playerStateStream.listen((state) {
      setState(() => isPlaying = state.playing);
    });
  }

  Future<void> _initAudio() async {
    int diaAudio = dia <= 7 ? dia : dia % 7;
    try {
      await _audioPlayer.setAsset(audiosSemana[diaAudio]!);
      await _audioPlayer.setVolume(1.0); // Volumen original del archivo
      await _audioPlayer.play(); // Reproducción automática
    } catch (e) {
      print("Error al cargar o reproducir audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _seekForward() {
    final newPosition = position + const Duration(seconds: 10);
    _audioPlayer.seek(newPosition < duration ? newPosition : duration);
  }

  void _seekBackward() {
    final newPosition = position - const Duration(seconds: 10);
    _audioPlayer.seek(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    int diaAudio = dia <= 7 ? dia : dia % 7;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _isDark
                  ? 'assets/images/meditacionfondo_dark.jpg'
                  : 'assets/images/meditacionfondo.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.35),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: IconButton(
                      icon: Icon(
                        _isDark ? Icons.nights_stay : Icons.wb_sunny,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => setState(() => _isDark = !_isDark),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset('assets/animations/ini.json', height: 250),
                    Lottie.asset('assets/animations/ini1.json', height: 220),
                    Image.asset(
                      _isDark
                          ? 'assets/images/mujerdark.png'
                          : 'assets/images/mujer.png',
                      height: 170,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tipsSemana[diaAudio]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white54,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10, color: Colors.white),
                          onPressed: _seekBackward,
                        ),
                        IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                          onPressed: _playPause,
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10, color: Colors.white),
                          onPressed: _seekForward,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position), style: const TextStyle(color: Colors.white)),
                          Text(_formatDuration(duration), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomePage(onThemeChanged: (bool isDark) {}),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isDark
                            ? const Color.fromARGB(255, 22, 4, 104)
                            : const Color.fromARGB(255, 255, 206, 238).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Terminar",
                          style: TextStyle(
                            color: _isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
