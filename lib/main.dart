import 'package:flutter/material.dart';
import 'config.dart';
import 'View/auth.dart';
import 'package:flutter_bugfender/flutter_bugfender.dart';

import 'View/book_management.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Config.initialize();
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
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const BookManagementApp(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
