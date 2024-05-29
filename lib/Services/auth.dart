import 'dart:convert';
import 'package:flutter_bugfender/flutter_bugfender.dart';

import 'package:http/http.dart' as http;
import 'package:my_library/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tuple/tuple.dart';

class Auth {
  static final Auth _instance = Auth._internal();
  final storage = FlutterSecureStorage();

  String? _token;

  // Singleton constructor
  Auth._internal();

  // Factory method to get the singleton instance
  factory Auth() {
    return _instance;
  }

  // Login function to authenticate user and get access token
  Future<Tuple2<bool, String>> loginWithEmailPassword(String email, String password) async {
    try {
      logout();
      final response = await http.post(
        Uri.parse('${Config().backendBaseUrl}/v1/auth/signin'),
        headers: {'Content-Type': 'application/json'}, // Add Content-Type header
        body: json.encode({ // Encode the request body as a JSON string
          "email": email,
          "password": password,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
        final responseData = json.decode(response.body);
        _token = responseData['token'];
        await storage.write(key: 'access_token', value: _token);
        return const Tuple2<bool, String>(true, "");
      }
      if (response.statusCode == 400){
        final responseData = json.decode(response.body);
        final errorMessage = responseData['detail'];
        final message = ('Failed to login: ${response.statusCode}, $errorMessage');
        return Tuple2<bool, String>(false, message);
      }
      else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['detail'][0]['ctx']['reason'];
        final message = ('Failed to login: ${response.statusCode}, $errorMessage');
        return Tuple2<bool, String>(false, message);
      }
    } catch (e) {
      return Tuple2<bool, String>(false, e.toString());
    }
  }
  
  // Function to add token to request headers
  Map<String, String> authHeaders() {
    return {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
  }

  // Check if the user is logged in
  Future<bool> isLoggedIn() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    if (token != null) {
      return true;
    } else {
      return false;
    }
  }

  // Register function to create a new user
  Future<Tuple2<bool, String>> registerWithEmailPassword(
    String email,
    String password,
    {String? name, double? timezone, String? username}
  ) async {
    try {
      logout();
      final response = await http.post(
        Uri.parse('${Config().backendBaseUrl}/v1/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": email,
          "password": password,
          if (name != null) "name": name,
          if (timezone != null) "timezone": timezone,
          if (username != null) "username": username
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
        final responseData = json.decode(response.body);
        _token = responseData['token'];
        await storage.write(key: 'access_token', value: _token);
        return const Tuple2<bool, String>(true, "");
      } else {
        final responseData = json.decode(response.body);
        FlutterBugfender.debug("Register failed: $responseData");
        final errorMessage = responseData['detail'][0]['ctx']['reason'];
        final message = ('Failed to register: ${response.statusCode}, $errorMessage');
        return Tuple2<bool, String>(false, message);
      }
    } catch (e) {
      return Tuple2<bool, String>(false, e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
  }
  

    /* TODO: return from be time valid and check here if still valid
    // check if the token is still valid if present
    if (token != null) {
      try {
        final response = await http.get(
          '${Config().backendBaseUrl}/user' as Uri,
          headers: _authHeaders(),
        );

        if (response.statusCode == 200) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
    */

  /* Example function to make authenticated API request
  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        '${Config().backendBaseUrl}/user' as Uri,
        headers: _authHeaders(),
      );

      if (response.statusCode == 200) {
        // Process response data
      } else {
        throw Exception('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }
  */
}
