import 'dart:convert';

class Book {
  final String title;
  final String? author;
  final String? genres;
  final String? cover;
  final String? idGoogle;
  final String? storyline;
  final DateTime? publicationDate;
  final String? language;

  Book({
    required this.title,
    required this.author,
    this.genres,
    this.cover,
    this.idGoogle,
    this.storyline,
    this.publicationDate,
    this.language,
  });

  Book.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        author = json['author'],
        genres = json['genres'],
        cover = json['cover'],
        idGoogle = json['id_google'],
        storyline = json['storyline'],
        publicationDate = json['publication_date'] != null ? DateTime.parse(json['publication_date']) : null,
        language = json['language'];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'genres': genres,
      'cover': cover,
      'id_google': idGoogle,
      'storyline': storyline,
      'publication_date': publicationDate?.toIso8601String(),
      'language': language,
    };
  }

  String serialize() {
    return jsonEncode(toJson());
  }

  static Book deserialize(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    return Book.fromJson(map);
  }

  Book copyWith({
    String? title,
    String? author,
    String? genres,
    String? cover,
    String? idGoogle,
    String? storyline,
    DateTime? publicationDate,
    String? language,
  }) {
    return Book(
      title: title ?? this.title,
      author: author ?? this.author,
      genres: genres ?? this.genres,
      cover: cover ?? this.cover,
      idGoogle: idGoogle ?? this.idGoogle,
      storyline: storyline ?? this.storyline,
      publicationDate: publicationDate ?? this.publicationDate,
      language: language ?? this.language,
    );
  }
}
