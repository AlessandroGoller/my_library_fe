
import 'package:my_library/controller/tag.dart';

Future<List<String>> getBooksTagsByIdAccountBook (int idAccountBook) async {
  List<String> tags = [];
  await Tag().getBooksTagsByIdAccountBook(idAccountBook).then((value) {
    for (var tag in value) {
      tags.add(tag.tag.name);
    }
  });
  return tags;
}