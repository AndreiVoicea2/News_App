import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/news_item.dart';
import 'screens/news_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;
  final Set<NewsItem> _favoriteNews = {};

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
        favoriteNews: _favoriteNews,
        onRemoveFavorite: (news) => setState(() => _favoriteNews.remove(news)),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final bool darkMode;
  final VoidCallback onToggleDarkMode;
  final Set<NewsItem> favoriteNews;
  final void Function(NewsItem) onRemoveFavorite;

  const HomePage({
    super.key,
    required this.darkMode,
    required this.onToggleDarkMode,
    required this.favoriteNews,
    required this.onRemoveFavorite,
  });

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
                  builder: (_) => FavoritePage(
                    favorites: favoriteNews,
                    onRemove: onRemoveFavorite,
                  ),
                ),
              );
            },
            child: Text(
              'Favorites',
              style: TextStyle(
                color: darkMode ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: onToggleDarkMode,
          ),
        ],
      ),
      body: NewsListPage(
        favoriteNews: favoriteNews,
        onOpenNews: (url) async {
          final uri = Uri.tryParse(url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open link')),
            );
          }
        },
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  final Set<NewsItem> favorites;
  final void Function(NewsItem) onRemove;

  const FavoritePage({super.key, required this.favorites, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final news = favorites.elementAt(index);
          return ListTile(
            title: Text(news.title),
            subtitle: Text('By ${news.author}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onRemove(news),
            ),
            onTap: () async {
              final uri = Uri.tryParse(news.url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open link')),
                );
              }
            },
          );
        },
      ),
    );
  }
}
