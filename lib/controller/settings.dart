import 'package:http/http.dart' as http;
import 'package:my_library/config.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';
import 'dart:io';

import 'package:my_library/Services/auth.dart';

class Settings {
  Future<File> downloadData() async {
    String baseUrl = Config().backendBaseUrl;
    try {
      var url = Uri.parse("$baseUrl/v1/settings/download");
      final response = await http.get(
        url,
        headers: Auth().authHeaders(),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to download data');
      }

      // Check content type to ensure it's a zip file
      String? contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/zip')) {
        FlutterBugfender.info("Data downloaded");
        // Return the downloaded data as a zip file
        return File('path/to/save/zip/file_temp.zip')..writeAsBytes(response.bodyBytes);
      } else {
        FlutterBugfender.info("Error during download    ");
        throw Exception('Invalid content type or not a zip file');
      }
    } catch (e) {
      FlutterBugfender.error("No data downloaded: $e");
      throw Exception('Error in downloading data');
    }
  }
}

