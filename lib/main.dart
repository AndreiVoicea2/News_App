/// The purpose of this project is to create a news app,
/// with a user-friendly interface and an efficient implementation.
///
/// Made by: Andrei Voicea
/// Project Location: https://github.com/AndreiVoicea2
///

import 'package:flutter/material.dart';
import 'screens/news_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;


  final ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    primaryColor: const Color(0xFFFFF8E1),
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFE0B2),
      foregroundColor: Colors.black,
    ),
    cardColor: const Color(0xFFFFF3E0),
  );


  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    primaryColor: Colors.grey[900],
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
    ),
    cardColor: Colors.grey[800],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: darkMode ? darkTheme : lightTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("News"),
        ),
        body: NewsListPage(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              darkMode = !darkMode;
            });
          },
          child: const Icon(Icons.brightness_6),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}
