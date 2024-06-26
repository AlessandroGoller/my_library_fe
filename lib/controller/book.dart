import 'dart:convert';      // required to encode/decode json data
import 'package:http/http.dart' as http;
import 'package:my_library/model/account_book.dart';

import 'package:my_library/model/book_google.dart';

import 'package:my_library/config.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';
import 'package:my_library/Services/auth.dart';

class Books {
  Future<List<AccountBookResponse>> getBooks() async {
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
      return body.map((e) => AccountBookResponse.fromJson(e)).toList();
    } catch (e) {
      FlutterBugfender.error("No books found: $e");
      throw Exception('Error in loading books');
    } 
  }

  Future<List<BookGoogle>> searchBook(String bookName) async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/books/search?search_query=$bookName");
      final response = await http.get(
        url,
        headers: Auth().authHeaders(),
        );
      if (response.statusCode != 200) {
        throw Exception('Failed to search books');
      }
      final List body = json.decode(response.body);
      return body.map((e) => BookGoogle.fromJson(e)).toList();
    } catch (e) {
      FlutterBugfender.error("No books found: $e");
      throw Exception('Error in search books');
    } 
  }

  Future<AccountBookResponse> addBook(BookGoogle bookGoogle) async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/account-books?id_google_book=${bookGoogle.id}");
      final response = await http.post(
        url,
        headers: Auth().authHeaders(),
        );
      if (response.statusCode != 201) {
        throw Exception('Failed to add book');
      }
      final body = json.decode(response.body);
      return AccountBookResponse.fromJson(body);
    } catch (e) {
      FlutterBugfender.error("No books found: $e");
      throw Exception('Error in add book');
    } 
  }

  Future<AccountBookResponse> editBook(AccountBookResponse accountBookResponse) async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/account-books/${accountBookResponse.idAccountBook}");
      final response = await http.put(
        url,
        headers: Auth().authHeaders(),
        body: json.encode(accountBookResponse.accountBook.toJson()),
        );
      if (response.statusCode != 200) {
        throw Exception('Failed to edit book');
      }
      final body = json.decode(response.body);
      return AccountBookResponse.fromJson(body);
    } catch (e) {
      FlutterBugfender.error("No books found: $e");
      throw Exception('Error in edit book');
    } 
  }

  Future<void> deleteBook(int idAccountBook) async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/account-books/$idAccountBook");
      final response = await http.delete(
        url,
        headers: Auth().authHeaders(),
        );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete book');
      }
    } catch (e) {
      FlutterBugfender.error("No books found: $e");
      throw Exception('Error in delete book');
    } 
  }
}