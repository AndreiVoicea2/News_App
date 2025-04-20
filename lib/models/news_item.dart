/// Class purpose: The NewsItem class is used to represent a news article with
/// specific attributes such as title, publicationDate, author, numComments,
/// points, and url. This class is designed to encapsulate the information
/// related to a single news article that can be displayed and interacted with
/// in the application.

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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'publicationDate': publicationDate,
      'author': author,
      'numComments': numComments,
      'points': points,
      'url': url,
    };
  }

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'],
      publicationDate: json['publicationDate'],
      author: json['author'],
      numComments: json['numComments'],
      points: json['points'],
      url: json['url'],
    );
  }


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
