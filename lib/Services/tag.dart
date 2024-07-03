
import 'package:my_library/controller/tag.dart';
import 'package:my_library/model/tag.dart';
import 'package:my_library/services/books_info.dart';

Future<List<String>> getBooksTagsByIdAccountBook (int idAccountBook) async {
  List<String> tags = [];
  await Tag().getBooksTagsByIdAccountBook(idAccountBook).then((value) {
    for (var tag in value) {
      tags.add(tag.tag.name);
    }
  });
  return tags;
}

Future<List<TagResponse>> getTags() async {
  List<TagResponse> tags = [];
  await BooksInfo().getTags().then((value) {
    tags = value;
  });
  return tags;
}