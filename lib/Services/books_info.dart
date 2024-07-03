import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/model/account_book.dart';
import 'package:my_library/model/tag.dart';
import 'package:my_library/controller/tag.dart';
import 'package:my_library/controller/book.dart';

class BooksInfo{

  final storage = FlutterSecureStorage();

  Future<void> updateAll() async {
    await updateTags();
    await updateBooks();
  }

  Future<List<TagResponse>> updateTags() async {
    List<TagResponse> tagresponse = await Tag().getTags();
    List<String> serializedTags = tagresponse.map((tag) => tag.serialize()).toList();
    await storage.write(key: 'tags', value: serializedTags.join(';'));
    return tagresponse;
  }

  Future<List<TagResponse>> getTags() async {
    String? tags = await storage.read(key: 'tags');
    if (tags == null) {
      return updateTags();
    }
    return tags.split(';').map((tag) => TagResponse.deserialize(tag)).toList();
  }

  Future<List<AccountBookResponse>> updateBooks() async {
    List<AccountBookResponse> accountBookResponse = await Books().getBooks();
    List<String> serializedBooks = accountBookResponse.map((book) => book.serialize()).toList();
    await storage.write(key: 'books', value: serializedBooks.join(';;'));
    return accountBookResponse;
  }

  Future<List<AccountBookResponse>> getBooks() async {
    String? books = await storage.read(key: 'books');
    if (books == null) {
      return updateBooks();
    }
    return books.split(';;').map((book) => AccountBookResponse.deserialize(book)).toList();
  }
}