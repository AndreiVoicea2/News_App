/// The purpose of this project is to create a news app,
/// with a user-friendly interface and an efficient implementation.
///
/// Made by: Andrei Voicea
/// Project Location: https://github.com/AndreiVoicea2
///

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/news_list_page.dart';
import 'models/news_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
      home: HomePage(
        darkMode: darkMode,
        onToggleDarkMode: () => setState(() => darkMode = !darkMode),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final bool darkMode;
  final VoidCallback onToggleDarkMode;

  const HomePage({super.key, required this.darkMode, required this.onToggleDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News', style: TextStyle(fontSize: 20)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritesPage(),
                ),
              );
            },
            child: Text(
              'Favorites',
              style: TextStyle(
                color: darkMode ? Colors.white : Colors.black,
                fontSize: 20.0,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: onToggleDarkMode,
          ),
        ],
      ),
      body: const NewsListPage(),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Future<List<NewsItem>> loadFavoriteItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> titles = prefs.getStringList('favorites') ?? [];
    return titles
        .map((title) => NewsItem(
      title: title,
      publicationDate: '',
      author: '',
      numComments: 0,
      points: 0,
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: loadFavoriteItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load favorites'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorites yet.'));
          }
          final favorites = snapshot.data!;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(item.title),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
