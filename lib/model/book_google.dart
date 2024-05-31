class BookGoogle {
  final String id;
  final String selfLink;
  final String title;
  final List<String>? authors;
  final String? description;
  final List<String>? categories;
  final String? imageLinks;
  final String? language;

  BookGoogle({
    required this.id,
    required this.selfLink,
    required this.title,
    this.authors,
    this.description,
    this.categories,
    this.imageLinks,
    this.language,
  });

  BookGoogle.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        selfLink = json['self_link'],
        title = json['title'],
        authors = json['authors'] != null ? List<String>.from(json['authors']) : null,
        description = json['description'],
        categories = json['categories'] != null ? List<String>.from(json['categories']) : null,
        imageLinks = json['image_links'],
        language = json['language'];
}
