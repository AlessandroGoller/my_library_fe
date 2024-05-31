class Book {
  final String title;
  final String author;
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
}
