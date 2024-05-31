
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
}
