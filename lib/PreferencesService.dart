/// Class purpose: To isolate and manage the saving and loading of
/// favorite news items from persistent storage (SharedPreferences).

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/news_item.dart';

class PreferencesService {
  static const String _favoritesKey = 'favoriteNews';

  static Future<void> saveFavoriteNews(Set<NewsItem> favoriteNews) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = favoriteNews.map((news) => json.encode({
      'title': news.title,
      'publicationDate': news.publicationDate,
      'author': news.author,
      'numComments': news.numComments,
      'points': news.points,
      'url': news.url,
    })).toList();
    await prefs.setStringList(_favoritesKey, jsonList);
  }

  static Future<Set<NewsItem>> loadFavoriteNews() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_favoritesKey);
    if (jsonList == null) return {};

    return jsonList.map((item) {
      final map = json.decode(item);
      return NewsItem(
        title: map['title'],
        publicationDate: map['publicationDate'],
        author: map['author'],
        numComments: map['numComments'],
        points: map['points'],
        url: map['url'],
      );
    }).toSet();
  }
}
