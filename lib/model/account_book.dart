
import 'package:my_library/model/book.dart';

class AccountBookResponse {
  final int idAccountBook;
  final Book book;
  final AccountBookBasic accountBook;

  AccountBookResponse({
    required this.idAccountBook,
    required this.book,
    required this.accountBook,
  });

  AccountBookResponse.fromJson(Map<String, dynamic> json)
      : idAccountBook = json['id_account_book'],
        book = Book.fromJson(json['book']),
        accountBook = AccountBookBasic.fromJson(json['account_book']);

  Map<String, dynamic> toJson() {
    return {
      'id_account_book': idAccountBook,
      'book': book.toJson(),
      'account_book': accountBook.toJson(),
    };
  }

  AccountBookResponse copyWith({
    int? idAccountBook,
    Book? book,
    AccountBookBasic? accountBook,
  }) {
    return AccountBookResponse(
      idAccountBook: idAccountBook ?? this.idAccountBook,
      book: book ?? this.book,
      accountBook: accountBook ?? this.accountBook,
    );
  }
}


class AccountBookBasic {
  final bool? isFavorite;
  final bool? isWishlist;
  final String? notes;
  final int? rating;
  final bool? isPhysical;
  final DateTime? readedAt;

  AccountBookBasic({
    this.isFavorite,
    this.isWishlist,
    this.notes,
    this.rating,
    this.isPhysical,
    this.readedAt,
  });

  AccountBookBasic.fromJson(Map<String, dynamic> json)
      : isFavorite = json['is_favorite'],
        isWishlist = json['is_wishlist'],
        notes = json['notes'],
        rating = json['rating'],
        isPhysical = json['is_physical'],
        readedAt = json['readed_at'] != null ? DateTime.parse(json['readed_at']) : null;

  Map<String, dynamic> toJson() {
    return {
      'is_favorite': isFavorite,
      'is_wishlist': isWishlist,
      'notes': notes,
      'rating': rating,
      'is_physical': isPhysical,
      'readed_at': readedAt?.toIso8601String(),
    };
  }
  AccountBookBasic copyWith({
    bool? isFavorite,
    bool? isWishlist,
    String? notes,
    int? rating,
    bool? isPhysical,
    DateTime? readedAt,
  }) {
    return AccountBookBasic(
      isFavorite: isFavorite ?? this.isFavorite,
      isWishlist: isWishlist ?? this.isWishlist,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      isPhysical: isPhysical ?? this.isPhysical,
      readedAt: readedAt ?? this.readedAt,
    );
  }
}
