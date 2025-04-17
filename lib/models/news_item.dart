class NewsItem {
  final String title;
  final String publicationDate;
  final String author;
  final int numComments;
  final int points;
  final String url;

  NewsItem({
    required this.title,
    required this.publicationDate,
    required this.author,
    required this.numComments,
    required this.points,
    required this.url,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NewsItem &&
              runtimeType == other.runtimeType &&
              title == other.title &&
              publicationDate == other.publicationDate;

  @override
  int get hashCode => title.hashCode ^ publicationDate.hashCode;
}
