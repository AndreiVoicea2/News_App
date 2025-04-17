import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_item.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage();

  @override
  _NewsListPageState createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  late Future<List<NewsItem>> _futureNews;
  final Set<int> _favoriteIndexes = {};

  @override
  void initState() {
    super.initState();
    _futureNews = fetchNews();
  }

  Future<List<NewsItem>> fetchNews() async {
    final response = await http.get(
      Uri.parse('https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=50'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hits = data['hits'] as List;
      return hits.map((item) => NewsItem(
        title: item['title'] ?? 'No Title',
        publicationDate: item['created_at'] ?? '',
        author: item['author'] ?? 'Unknown',
        numComments: item['num_comments'] ?? 0,
        points: item['points'] ?? 0,
      )).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsItem>>(
      future: _futureNews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data'));
        }
        final newsItems = snapshot.data!;
        return ListView.builder(
          itemCount: newsItems.length,
          itemBuilder: (context, index) {
            final news = newsItems[index];
            final isFavorite = _favoriteIndexes.contains(index);
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    news.publicationDate,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'By ${news.author}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.comment, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${news.numComments}'),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${news.points}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: isFavorite ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isFavorite) {
                                _favoriteIndexes.remove(index);
                              } else {
                                _favoriteIndexes.add(index);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}