// lib/data/tip_data.dart
import '../models/tip_model.dart';

final List<TipModel> tips = [
  TipModel(
    id: "pomodoro",
    title: "Pomodoro",
    subtitle: "Divide tu tiempo en bloques",
    imagePath: "assets/images/pomodoro.png",
    details: ["25 minutos de trabajo", "5 minutos de descanso", "Repite el ciclo"], lottieMain: '', lottieOverlay: '',
  ),
  TipModel(
    id: "mapas",
    title: "Mapas Mentales",
    subtitle: "Organiza tus ideas",
    imagePath: "assets/images/MAPASMENTALES.png",
    details: ["Usa colores", "Conecta conceptos", "Facilita la memoria"], lottieMain: '', lottieOverlay: '',
  ),
  TipModel(
    id: "flashcards",
    title: "Flash Cards",
    subtitle: "Repasa con tarjetas",
    imagePath: "assets/images/flashcards.png",
    details: ["Pregunta y respuesta", "Memoria activa", "Práctica diaria"], lottieMain: '', lottieOverlay: '',
  ),
  TipModel(
    id: "resumenes",
    title: "Resúmenes",
    subtitle: "Sintetiza lo aprendido",
    imagePath: "assets/images/resumenes.png",
    details: ["Palabras clave", "Ideas principales", "Formato breve"], lottieMain: '', lottieOverlay: '',
  ),
  TipModel(
    id: "lectura",
    title: "Lectura Activa",
    subtitle: "Comprensión profunda",
    imagePath: "assets/images/resumenes(1).png",
    details: ["Subraya ideas", "Haz anotaciones", "Relaciona conceptos"], lottieMain: '', lottieOverlay: '',
  ),
  TipModel(
    id: "vozalta",
    title: "Explicar en Voz Alta",
    subtitle: "Refuerza con tu voz",
    imagePath: "assets/images/vozalta.png",
    details: ["Explica como profesor", "Identifica dudas", "Mejora retención"], lottieMain: '', lottieOverlay: '',
  ),
  TipModel(
    id: "planificacion",
    title: "Planificación Semanal",
    subtitle: "Organiza tu semana",
    imagePath: "assets/images/planificacionsemanal.png",
    details: ["Asigna horarios", "Equilibra materias", "Incluye descansos"], lottieMain: '', lottieOverlay: '',
  ),
];
