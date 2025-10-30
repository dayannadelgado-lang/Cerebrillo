import 'package:cloud_firestore/cloud_firestore.dart';

class ListMoviesVariablesBuilder {
  ListMoviesVariablesBuilder();

  Future<ListMoviesData> execute() async {
    final snapshot = await FirebaseFirestore.instance.collection('movies').get();

    List<ListMoviesMovies> movies = snapshot.docs.map((doc) {
      final data = doc.data();
      return ListMoviesMovies(
        id: doc.id,
        title: data['title'] ?? '',
        imageUrl: data['imageUrl'] ?? '',
        genre: data['genre'],
      );
    }).toList();

    return ListMoviesData(movies: movies);
  }
}

// ────────────── MODEL CLASSES ──────────────
class ListMoviesMovies {
  String id;
  String title;
  String imageUrl;
  String? genre;

  ListMoviesMovies({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.genre,
  });

  factory ListMoviesMovies.fromJson(Map<String, dynamic> json) {
    return ListMoviesMovies(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      genre: json['genre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      if (genre != null) 'genre': genre,
    };
  }
}

class ListMoviesData {
  List<ListMoviesMovies> movies;

  ListMoviesData({required this.movies});

  factory ListMoviesData.fromJson(Map<String, dynamic> json) {
    return ListMoviesData(
      movies: (json['movies'] as List<dynamic>)
          .map((e) => ListMoviesMovies.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movies': movies.map((e) => e.toJson()).toList(),
    };
  }
}
