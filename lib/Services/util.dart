import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_bugfender/flutter_bugfender.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';


void showCustomDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class FileDownloaderHelper {
  static Future<void> saveFileOnDevice(String fileName, File inFile) async {
    try {
      if (Platform.isAndroid) {
        // Check if permission is granted
        if (await _requestWritePermission()) {
          // Proceed with saving the file
          final directory = Directory("/storage/emulated/0/Download");

          if (!directory.existsSync()) {
            // Create the directory if it doesn't exist
            await directory.create();
          }
          final path = '${directory.path}/$fileName';
          final bytes = await inFile.readAsBytes();
          final outFile = File(path);

          final res = await outFile.writeAsBytes(bytes, flush: true);
          FlutterBugfender.info("=> saved file: ${res.path}");
        } else {
          // Handle permission denial
          throw Exception("Write permission denied");
        }
      } else {
        // IOS
        final directory = await getApplicationDocumentsDirectory();
        // Get the application documents directory path
        final path = '${directory.path}/$fileName';
        final bytes = await inFile.readAsBytes();
        final res = await Share.shareXFiles([XFile(path, bytes: bytes)]);
        FlutterBugfender.info("=> saved status: ${res.status}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<bool> _requestWritePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }
}