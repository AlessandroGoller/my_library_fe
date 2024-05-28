import 'package:flutter/material.dart';
import 'config.dart';
import 'View/auth.dart';
import 'package:my_library/Services/auth.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

import 'View/book_management.dart';

void main() async{
  await Config.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBugfender.handleUncaughtErrors(() async {
    await FlutterBugfender.init("8hAMI9Lx0RcAujHCNNE0OkCgdvswBZQ0",
        enableCrashReporting: true, // these are optional, but recommended
        enableUIEventLogging: true,
        enableAndroidLogcatLogging: true);
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Library App',
      theme: ThemeData(
        // Your theme data
      ),
      home: FutureBuilder<bool>(
        future: Auth().isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Or a loading indicator
          } else {
            if (snapshot.data == true) {
              FlutterBugfender.log("Book Management App");
              return BookManagementApp();
            } else {
              FlutterBugfender.log("Login Screen");
              return LoginScreen();
            }
          }
        },
      ),
    );
  }
}
