import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static final Config _instance = Config._internal();

  // Configuration variables
  late final String backendServerHost;
  late final int backendServerPort;
  late final String backendBaseUrl;

  // Private constructor for singleton
  Config._internal();

  // Factory method to get the singleton instance
  factory Config() {
    return _instance;
  }

  // Method to initialize the configuration
  static Future<void> initialize() async {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Initialize configuration variables
    _instance._initializeFromEnv();
  }

  // Private method to initialize configuration from environment variables
  void _initializeFromEnv() {
    backendServerHost = dotenv.env['BACKEND_SERVER_HOST']!;
    // backendServerPort = int.parse(dotenv.env['BACKEND_SERVER_PORT']!);
    // backendBaseUrl = 'http://$backendServerHost:$backendServerPort';
    backendBaseUrl = 'https://$backendServerHost';
  }
}
