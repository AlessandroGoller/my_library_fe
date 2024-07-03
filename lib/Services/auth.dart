import 'dart:convert';
import 'package:flutter_bugfender/flutter_bugfender.dart';
import 'package:http/http.dart' as http;
import 'package:my_library/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tuple/tuple.dart';
import 'dart:async';

class Auth {
  static final Auth _instance = Auth._internal();
  final storage = FlutterSecureStorage();

  String? _token;
  String? _refreshToken;
  DateTime? _expiryTime;
  Timer? _tokenRefreshTimer;

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
        _refreshToken = responseData['refresh_token'];
        _expiryTime = DateTime.now().add(Duration(seconds: responseData['expires_in']));
        
        await storage.write(key: 'access_token', value: _token);
        await storage.write(key: 'refresh_token', value: _refreshToken);
        await storage.write(key: 'expiry_time', value: _expiryTime!.toIso8601String());

        _startTokenRefreshTimer();

        return const Tuple2<bool, String>(true, "");
      }

      if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['detail'];
        final message = ('Failed to login: ${response.statusCode}, $errorMessage');
        return Tuple2<bool, String>(false, message);
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['detail'][0]['ctx']['reason'];
        final message = ('Failed to login: ${response.statusCode}, $errorMessage');
        return Tuple2<bool, String>(false, message);
      }
    } catch (e) {
      return Tuple2<bool, String>(false, e.toString());
    }
  }

  // Start the timer to refresh token before it expires
  void _startTokenRefreshTimer() {
    final timeToRefresh = _expiryTime!.difference(DateTime.now()).inSeconds - 60;
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer(Duration(seconds: timeToRefresh), _refreshTokenAutomatically);
  }

  // Refresh token automatically
  Future<void> _refreshTokenAutomatically() async {
    try {
      final response = await http.post(
        Uri.parse('${Config().backendBaseUrl}/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"refresh_token": _refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
        final responseData = json.decode(response.body);
        _token = responseData['token'];
        _expiryTime = DateTime.now().add(Duration(seconds: responseData['expires_in']));

        await storage.write(key: 'access_token', value: _token);
        await storage.write(key: 'expiry_time', value: _expiryTime!.toIso8601String());

        _startTokenRefreshTimer();
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
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
    final token = await storage.read(key: 'access_token');
    final expiryTimeStr = await storage.read(key: 'expiry_time');
    if (token != null && expiryTimeStr != null) {
      _expiryTime = DateTime.parse(expiryTimeStr);
      if (_expiryTime!.isAfter(DateTime.now())) {
        _token = token;
        _startTokenRefreshTimer();
        return true;
      } else {
        await _refreshTokenAutomatically();
        return _token != null;
      }
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
        _refreshToken = responseData['refresh_token'];
        _expiryTime = DateTime.now().add(Duration(seconds: responseData['expires_in']));

        await storage.write(key: 'access_token', value: _token);
        await storage.write(key: 'refresh_token', value: _refreshToken);
        await storage.write(key: 'expiry_time', value: _expiryTime!.toIso8601String());

        _startTokenRefreshTimer();

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
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'expiry_time');
    await storage.deleteAll();
    _token = null;
    _refreshToken = null;
    _expiryTime = null;
    _tokenRefreshTimer?.cancel();
  }
}
