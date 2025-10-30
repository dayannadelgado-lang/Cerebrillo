import 'package:cloud_firestore/cloud_firestore.dart';

class SearchMovieVariablesBuilder {
  String? titleInput;
  String? genre;

  SearchMovieVariablesBuilder();

  SearchMovieVariablesBuilder setTitle(String? t) {
    titleInput = t;
    return this;
  }

  SearchMovieVariablesBuilder setGenre(String? g) {
    genre = g;
    return this;
  }

  Future<SearchMovieData> execute() async {
    Query query = FirebaseFirestore.instance.collection('movies');

    if (titleInput != null && titleInput!.isNotEmpty) {
      query = query.where('title', isEqualTo: titleInput);
    }
    if (genre != null && genre!.isNotEmpty) {
      query = query.where('genre', isEqualTo: genre);
    }

    final snapshot = await query.get();

    List<SearchMovieMovies> movies = snapshot.docs.map((doc) {
      final data = doc.data();
      if (data == null) return null;

      return SearchMovieMovies(
        id: doc.id,
        title: data['title'] as String? ?? '',
        genre: data['genre'] as String?,
        imageUrl: data['imageUrl'] as String? ?? '',
      );
    }).whereType<SearchMovieMovies>().toList();

    return SearchMovieData(movies: movies);
  }
}

extension on Object {
  void operator [](String other) {}
}

// ────────────── MODELS ──────────────
class SearchMovieMovies {
  String id;
  String title;
  String? genre;
  String imageUrl;

  SearchMovieMovies({
    required this.id,
    required this.title,
    this.genre,
    required this.imageUrl,
  });

  factory SearchMovieMovies.fromJson(Map<String, dynamic> json) {
    return SearchMovieMovies(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      genre: json['genre'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (genre != null) 'genre': genre,
      'imageUrl': imageUrl,
    };
  }
}

class SearchMovieData {
  List<SearchMovieMovies> movies;

  SearchMovieData({required this.movies});

  factory SearchMovieData.fromJson(Map<String, dynamic> json) {
    return SearchMovieData(
      movies: (json['movies'] as List<dynamic>? ?? [])
          .map((e) => SearchMovieMovies.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movies': movies.map((e) => e.toJson()).toList(),
    };
  }
}
