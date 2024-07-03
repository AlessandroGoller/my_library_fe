
import 'package:my_library/model/account_book.dart';
import 'dart:convert';

class TagResponse {
  final int idTag;
  final String name;
  final DateTime createdAt;

  TagResponse({
    required this.idTag,
    required this.name,
    required this.createdAt,
  });

  TagResponse.fromJson(Map<String, dynamic> json)
      : idTag = json['id_tag'],
        name = json['name'],
        createdAt = DateTime.parse(json['created_at']);
  
  Map<String, dynamic> toMap() {
    return {
      'id_tag': idTag,
      'name': name,
      'created_at': createdAt,
    };
  }

  String serialize() {
    return jsonEncode({
      'id_tag': idTag,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    });
  }

  static TagResponse deserialize(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    return TagResponse.fromJson(map);
  }
}

class BooksTagsResponse {
  final int idBooksTags;
  final TagResponse tag;
  final AccountBookResponse accountBook;

  BooksTagsResponse({
    required this.idBooksTags,
    required this.tag,
    required this.accountBook,
  });

  BooksTagsResponse.fromJson(Map<String, dynamic> json)
      : idBooksTags = json['id_books_tags'],
        tag = TagResponse.fromJson(json['tag']),
        accountBook = AccountBookResponse.fromJson(json['account_book']);
}

class CreateBooksTags {
  final String nameTag;
  final int idAccountBook;

  CreateBooksTags({
    required this.nameTag,
    required this.idAccountBook,
  });

  Map<String, dynamic> toJson() {
    return {
      'name_tag': nameTag,
      'id_account_book': idAccountBook,
    };
  }
}