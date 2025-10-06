// ignore_for_file: strict_top_level_inference

class TipModel {
  final String id;
  final String title;
  final String subtitle;
  final String lottieMain;      // archivo lottie principal
  final List<String> details;   // tiras de info (solo la info, sin títulos)

  TipModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lottieMain,
    required this.details, required String lottieOverlay, required String imagePath,
  });

  String get name => title;

  get lottieOverlay => null;

  static TipModel? fromMap(Map<String, dynamic> map) {
    return null;
  }
}
