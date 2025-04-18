import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/news_item.dart';

class NewsListPage extends StatefulWidget {
  final Set<NewsItem> favoriteNews;
  final void Function(String) onOpenNews;

  const NewsListPage({
    required this.favoriteNews,
    required this.onOpenNews,
  });

  @override
  _NewsListPageState createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  late Future<List<NewsItem>> _futureNews;
  String _searchQuery = '';
  String _filterOption = 'None';
  String _sortOption = 'None';
  double _minPoints = 0;
  double _maxPoints = 500;
  DateTime _startDate = DateTime(2020);
  DateTime _endDate = DateTime.now();
  bool _showRange = false;

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
        url: item['url'] ?? '',
      )).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }

  List<NewsItem> applyFilters(List<NewsItem> newsItems) {
    List<NewsItem> filtered = newsItems
        .where((news) => news.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    switch (_filterOption) {
      case 'Points':
        filtered = filtered
            .where((news) => news.points >= _minPoints && news.points <= _maxPoints)
            .toList();
        break;
      case 'Date':
        filtered = filtered
            .where((news) {
          final publicationDate = DateTime.parse(news.publicationDate);
          return publicationDate.isAfter(_startDate) && publicationDate.isBefore(_endDate);
        })
            .toList();
        break;
    }

    switch (_sortOption) {
      case 'Points':
        filtered.sort((a, b) => b.points.compareTo(a.points));
        break;
      case 'Date':
        filtered.sort((a, b) => b.publicationDate.compareTo(a.publicationDate));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search by title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 8),


              DropdownButton<String>(
                value: _sortOption,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'None', child: Text('None')),
                  DropdownMenuItem(value: 'Points', child: Text('Sort by Points')),
                  DropdownMenuItem(value: 'Date', child: Text('Sort by Date')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortOption = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),


              DropdownButton<String>(
                value: _filterOption,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'None', child: Text('No Filter')),
                  DropdownMenuItem(value: 'Points', child: Text('Filter by Points')),
                  DropdownMenuItem(value: 'Date', child: Text('Filter by Date')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterOption = value!;
                    _showRange = value != 'None';
                  });
                },
              ),
            ],
          ),
        ),

        // Range filter UI
        if (_showRange)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                if (_filterOption == 'Points')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Points Range:'),
                      RangeSlider(
                        values: RangeValues(_minPoints, _maxPoints),
                        min: 0,
                        max: 500,
                        divisions: 100,
                        labels: RangeLabels(
                          _minPoints.round().toString(),
                          _maxPoints.round().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _minPoints = values.start;
                            _maxPoints = values.end;
                          });
                        },
                      ),
                    ],
                  ),
                if (_filterOption == 'Date')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date Range:'),
                      RangeSlider(
                        values: RangeValues(
                          _startDate.millisecondsSinceEpoch.toDouble(),
                          _endDate.millisecondsSinceEpoch.toDouble(),
                        ),
                        min: DateTime(2020).millisecondsSinceEpoch.toDouble(),
                        max: DateTime.now().millisecondsSinceEpoch.toDouble(),
                        divisions: 100,
                        labels: RangeLabels(
                          DateFormat.yMd().format(_startDate),
                          DateFormat.yMd().format(_endDate),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _startDate = DateTime.fromMillisecondsSinceEpoch(values.start.toInt());
                            _endDate = DateTime.fromMillisecondsSinceEpoch(values.end.toInt());
                          });
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),

        // News List
        Expanded(
          child: FutureBuilder<List<NewsItem>>(
            future: _futureNews,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data'));
              }

              final filteredNews = applyFilters(snapshot.data!);
              return ListView.builder(
                itemCount: filteredNews.length,
                itemBuilder: (context, index) {
                  final news = filteredNews[index];
                  final isFavorite = widget.favoriteNews.contains(news);
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
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
                                  widget.favoriteNews.remove(news);
                                } else {
                                  widget.favoriteNews.add(news);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ).applyOnTap(() => widget.onOpenNews(news.url));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

extension CardTapExtension on Widget {
  Widget applyOnTap(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: this,
    );
  }
}
