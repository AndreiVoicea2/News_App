import 'package:flutter/material.dart';
import '../models/news_item.dart';

class NewsListPage extends StatelessWidget {

  final List<NewsItem> newsItems = [
    NewsItem(
      title: 'Trump flexes power over the law',
      publicationDate: '2025-04-15',
      author: 'CNN',
      numComments: 35,
      points: 120,
    ),
    NewsItem(
      title: '25 years on, Patrick Bateman’s unsettling morning routine is normal',
      publicationDate: '2025-04-15',
      author: 'CNN',
      numComments: 22,
      points: 90,
    ),
    NewsItem(
      title: 'UNESCO has designated a Global Geopark in this unexpected country',
      publicationDate: '2025-04-15',
      author: 'CNN',
      numComments: 18,
      points: 70,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: newsItems.length,
          itemBuilder: (context, index) {
            final news = newsItems[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
            );
          },
        ),
      ],
    );
  }
}
