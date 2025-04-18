import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_item.dart';

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
