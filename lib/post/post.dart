
class BlogPost {
  int? id;
  final String title;
  final String description;
  final String url;
  final DateTime creationDate;

  BlogPost({
    this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.creationDate,
    });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'description': description,
      'creationDate': creationDate.toIso8601String(),
    };
  }
}
