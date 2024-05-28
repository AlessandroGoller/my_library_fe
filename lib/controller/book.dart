import 'dart:convert';      // required to encode/decode json data
import 'package:http/http.dart' as http;
import 'package:my_library/model/book.dart';
import 'package:my_library/config.dart';
import 'package:my_library/Services/util.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';
import 'package:my_library/Services/auth.dart';

class GetBooks {
  Future<List<Book>> getBooks() async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/account-books");
      final response = await http.get(
        url,
        headers: Auth().authHeaders(),
        );
      if (response.statusCode != 200) {
        throw Exception('Failed to load books');
      }
      final List body = json.decode(response.body);
      return body.map((e) => Book.fromJson(e)).toList();
    } catch (e) {
      FlutterBugfender.error("No books found: $e");
      return [];
    } 
  }
}