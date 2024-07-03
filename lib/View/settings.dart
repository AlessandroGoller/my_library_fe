import 'package:flutter/material.dart';
import 'package:my_library/controller/settings.dart';
import 'dart:io';
import 'package:my_library/Services/util.dart';
import 'package:my_library/Services/permission_helper.dart';
import 'package:my_library/Services/auth.dart';


class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Download all your personal data',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _confirmAction(
                context,
                'download all your personal data',
                () => _downloadData(context),
              ),
              child: Text('Download Data'),
            ),
            SizedBox(height: 24),
            Text(
              'Delete all your personal data',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => _confirmAction(
                context,
                'delete all your personal data',
                () => _deleteData(context),
              ),
              child: Text('Delete Data'),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadData(BuildContext context) async {
    try {
      // Show snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data download initiated')),
      );

      // Initiate download
      File data = await Settings().downloadData();

      String filename = 'personal_data.zip';

      final granted = await PermissionHelper.requestStoragePermissions();
      if (!granted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
        return;
      };

      FileDownloaderHelper.saveFileOnDevice(filename,data);

      // Show snackbar message after download completion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data download completed, file can be found in Downloads folder')),
      );
      return;

    } catch (e) {
      // Handle download errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading data: $e')),
      );
    }
  }

  void _deleteData(BuildContext context) {
    try {
      // Initiate data deletion
      Settings().deleteData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data deletion initiated')),
      );
    } catch (e) {
      // Handle deletion errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting data: $e')),
      );
      return;
    }
    // Implement logic to delete personal data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data deletion completed')),
    );
    Auth().logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _confirmAction(
      BuildContext context, String action, Function() onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $action'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to $action?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
