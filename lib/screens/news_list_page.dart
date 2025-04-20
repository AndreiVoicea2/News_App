/// Class purpose: stateful widget that serves as the main screen for displaying
/// a list of news articles, including filtering, sorting, searching, and
/// favoriting functionality.

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/news_item.dart';
import '../PreferencesService.dart';



class NewsListPage extends StatefulWidget {
  late Set<NewsItem> favoriteNews;
  final void Function(String) onOpenNews;

  NewsListPage({
    required this.favoriteNews,
    required this.onOpenNews,

  });

  @override
  _NewsListPageState createState() => _NewsListPageState();
}


class _NewsListPageState extends State<NewsListPage> {
  late Future<List<NewsItem>> _futureNews;
  String _searchQuery = '';
  String _sortOption = 'None';
  String _filterBy = 'None';

  double _minPoints = 0;
  double _maxPoints = 500;


  late final double _dateLimitMin;
  late final double _dateLimitMax;
  late double _minDateValue;
  late double _maxDateValue;

  final DateFormat _dateFmt = DateFormat.yMMMd();



  @override
  void initState() {
    super.initState();

    PreferencesService.loadFavoriteNews().then((favorites) {
      setState(() {
        widget.favoriteNews.addAll(favorites);
      });
    });

    final now = DateTime.now();
    _dateLimitMax = now.millisecondsSinceEpoch.toDouble();
    _dateLimitMin = now
        .subtract(const Duration(days: 365))
        .millisecondsSinceEpoch
        .toDouble();


    _minDateValue =
        now.subtract(const Duration(days: 30)).millisecondsSinceEpoch.toDouble();
    _maxDateValue = _dateLimitMax;

    _futureNews = fetchNews();
  }

  Future<List<NewsItem>> fetchNews() async {
    final response = await http.get(Uri.parse(
        'https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=50'));
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

  List<NewsItem> applyFilters(List<NewsItem> items) {
    var filtered = items
        .where((news) =>
        news.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (_filterBy == 'Points') {
      filtered = filtered
          .where((n) => n.points >= _minPoints && n.points <= _maxPoints)
          .toList();
    } else if (_filterBy == 'Date') {
      final start = DateTime.fromMillisecondsSinceEpoch(_minDateValue.toInt());
      final end = DateTime.fromMillisecondsSinceEpoch(_maxDateValue.toInt());
      filtered = filtered.where((n) {
        final pd = DateTime.tryParse(n.publicationDate);
        return pd != null && !pd.isBefore(start) && !pd.isAfter(end);
      }).toList();
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
    final accent = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search by title',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _sortOption,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'None', child: Text('No Sorting')),
                DropdownMenuItem(
                    value: 'Points', child: Text('Sort by Points')),
                DropdownMenuItem(value: 'Date', child: Text('Sort by Date')),
              ],
              onChanged: (v) => setState(() => _sortOption = v!),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _filterBy,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'None', child: Text('No Filter')),
                DropdownMenuItem(
                    value: 'Points', child: Text('Filter by Points')),
                DropdownMenuItem(value: 'Date', child: Text('Filter by Date')),
              ],
              onChanged: (v) => setState(() => _filterBy = v!),
            ),
            const SizedBox(height: 8),


            if (_filterBy == 'Points') ...[
              const Text('Points Range:'),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: accent,
                  inactiveTrackColor: accent.withOpacity(0.3),
                  thumbColor: accent,
                  overlayColor: accent.withOpacity(0.2),
                ),
                child: RangeSlider(
                  values: RangeValues(_minPoints, _maxPoints),
                  min: 0,
                  max: 500,
                  divisions: 100,
                  labels: RangeLabels(
                    _minPoints.round().toString(),
                    _maxPoints.round().toString(),
                  ),
                  onChanged: (r) =>
                      setState(() {
                        _minPoints = r.start;
                        _maxPoints = r.end;
                      }),
                ),
              ),
            ]

            else if (_filterBy == 'Date') ...[
              const Text('Publication Date Range:'),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: accent,
                  inactiveTrackColor: accent.withOpacity(0.3),
                  thumbColor: accent,
                  overlayColor: accent.withOpacity(0.2),
                ),
                child: RangeSlider(
                  values: RangeValues(_minDateValue, _maxDateValue),
                  min: _dateLimitMin,
                  max: _dateLimitMax,
                  divisions: 365,
                  labels: RangeLabels(
                    _dateFmt
                        .format(DateTime.fromMillisecondsSinceEpoch(
                        _minDateValue.toInt())),
                    _dateFmt
                        .format(DateTime.fromMillisecondsSinceEpoch(
                        _maxDateValue.toInt())),
                  ),
                  onChanged: (r) =>
                      setState(() {
                        _minDateValue = r.start;
                        _maxDateValue = r.end;
                      }),
                ),
              ),
            ],
          ]),
        ),
        Expanded(
          child: FutureBuilder<List<NewsItem>>(
            future: _futureNews,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              } else if (snap.data!.isEmpty) {
                return const Center(child: Text('No data'));
              }
              final list = applyFilters(snap.data!);
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (c, i) {
                  final news = list[i];
                  final fav = widget.favoriteNews.contains(news);
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(news.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  const SizedBox(height: 6),
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            news.publicationDate
                                                .split('T')
                                                .first,
                                            style: TextStyle(
                                                color:
                                                Colors.grey[600])),
                                        Text('By ${news.author}',
                                            style: TextStyle(
                                                color:
                                                Colors.grey[600])),
                                      ]),
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    const Icon(Icons.comment,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('${news.numComments}'),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.thumb_up,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('${news.points}'),
                                  ]),
                                ]),
                          ),
                          IconButton(
                            icon: Icon(fav ? Icons.star : Icons.star_border,
                                color: fav ? Colors.amber : Colors.grey),
                            onPressed: () => setState(() {
                              if (fav)
                                widget.favoriteNews.remove(news);
                              else
                                widget.favoriteNews.add(news);

                              PreferencesService.saveFavoriteNews(widget.favoriteNews);
                            }),

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
  Widget applyOnTap(VoidCallback onTap) => InkWell(onTap: onTap, child: this);
}
