import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_library/config.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

import 'package:my_library/model/tag.dart';
import 'package:my_library/Services/auth.dart';

class Tag {
  Future<List<TagResponse>> getTags() async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/tags");
      final response = await http.get(
        url,
        headers: Auth().authHeaders(),
        );
      if (response.statusCode != 200) {
        throw Exception('Failed to load tags');
      }
      final List body = json.decode(response.body);
      return body.map((e) => TagResponse.fromJson(e)).toList();
    } catch (e) {
      FlutterBugfender.error("No tags found: $e");
      return [];
    } 
  }

  Future<BooksTagsResponse> getBooksTagsByIdBooksTags(int idBooksTags) async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/books_tags/$idBooksTags");
      final response = await http.get(
        url,
        headers: Auth().authHeaders(),
        );
      if (response.statusCode != 200) {
        throw Exception('Failed to load books tags');
      }
      final body = json.decode(response.body);
      return BooksTagsResponse.fromJson(body);
    } catch (e) {
      FlutterBugfender.error("No books tags found: $e");
      throw Exception('Error in loading books tags');
    } 
  }

  Future<List<BooksTagsResponse>> getBooksTagsByIdAccountBook(int idAccountBook) async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/books_tags/account_book/$idAccountBook");
      final response = await http.get(
        url,
        headers: Auth().authHeaders(),
        );
      if (response.statusCode != 200) {
        throw Exception('Failed to load books tags');
      }
      final List body = json.decode(response.body);
      return body.map((e) => BooksTagsResponse.fromJson(e)).toList();
    } catch (e) {
      FlutterBugfender.error("No books tags found: $e");
      return [];
    } 
  }

  Future<void> deleteBooksTags(int idBooksTags) async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/books_tags/$idBooksTags");
      final response = await http.delete(
        url,
        headers: Auth().authHeaders(),
        );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete books tags');
      }
    } catch (e) {
      FlutterBugfender.error("No books tags found: $e");
      throw Exception('Error in deleting books tags');
    } 
  }

  Future<void> deleteBooksTagsByNameTagAndIdAccountBook(String nameTag, int idAccountBook) async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/books_tags/account_book/$idAccountBook/name_tag/$nameTag");
      final response = await http.delete(
        url,
        headers: Auth().authHeaders(),
        );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete books tags');
      }
    } catch (e) {
      FlutterBugfender.error("No books tags found: $e");
      throw Exception('Error in deleting books tags');
    } 
  }

  Future<void> deleteTag(int idTag) async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/tags/$idTag");
      final response = await http.delete(
        url,
        headers: Auth().authHeaders(),
        );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete tag');
      }
    } catch (e) {
      FlutterBugfender.error("No tag found: $e");
      throw Exception('Error in deleting tag');
    } 
  }

  Future<BooksTagsResponse> addBooksTags(CreateBooksTags createBooksTags) async {
    String baseUrl = Config().backendBaseUrl;
    try{
      var url = Uri.parse("$baseUrl/v1/books_tags");
      final response = await http.post(
        url,
        headers: Auth().authHeaders(),
        body: json.encode(createBooksTags.toJson()),
        );

      if (response.statusCode != 201) {
        throw Exception('Failed to add books tags\nProbably Tag already exists');
      }
      final body = json.decode(response.body);
      return BooksTagsResponse.fromJson(body);
    } catch (e) {
      FlutterBugfender.error("No books tags found: $e");
      throw Exception('Error in adding books tags');
    }
  }
}