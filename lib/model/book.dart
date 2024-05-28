class Book {
  final int id;
  final String title;
  final String? author;
  final String? coverImageUrl;
  final String? review;
  final DateTime? publicationDate;
  final DateTime? readeddate;
  final int? rating;
  final String? notes;

  Book({
    required this.id,
    required this.title,
    this.author,
    this.coverImageUrl,
    this.review,
    this.publicationDate,
    this.readeddate,
    this.rating,
    this.notes,
  });

  Book.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'].toString(),
        author = json['author'],
        coverImageUrl = json['cover'],
        review = json['review'],
        readeddate = json['readeddate'] != null ? DateTime.parse(json['readeddate']) : null,
        publicationDate = json['publicationDate'] != null ? DateTime.parse(json['publicationDate']) : null,
        rating = json['rating'] != null ? int.tryParse(json['rating'].toString()) : null,
        notes = json['notes'];
}