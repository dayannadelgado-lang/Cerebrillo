import 'package:cloud_firestore/cloud_firestore.dart';

class CreateMovieVariables {
  String title;
  String genre;
  String imageUrl;

  CreateMovieVariables({
    required this.title,
    required this.genre,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'genre': genre,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class CreateMovieData {
  String id; // Document ID en Firestore
  CreateMovieData({required this.id});
}

class CreateMovie {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CreateMovieData> execute(CreateMovieVariables vars) async {
    final docRef = await _firestore.collection('movies').add(vars.toJson());
    return CreateMovieData(id: docRef.id);
  }
}
