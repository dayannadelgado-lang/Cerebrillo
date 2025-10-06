import 'dart:convert';
import 'package:flutter/services.dart';

class SurveyService {
  SurveyService._privateConstructor();
  static final SurveyService instance = SurveyService._privateConstructor();

  Future<List<Map<String, dynamic>>> loadSurvey(String path) async {
    try {
      final String response = await rootBundle.loadString(path);
      final data = await json.decode(response) as List;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Error al cargar encuesta: $e');
    }
  }
}
