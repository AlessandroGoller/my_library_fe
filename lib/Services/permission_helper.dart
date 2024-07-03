import 'package:flutter_bugfender/flutter_bugfender.dart';

import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermissions() async {
    var status = await Permission.storage.status;
    FlutterBugfender.info("=> storage permission satus: $status");
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    return status == PermissionStatus.granted;
  }
}