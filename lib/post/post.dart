
class BlogPost {
  int? id;
  final String title;
  final String description;
  final String url;
  final String imagePath;
  final DateTime creationDate;

  BlogPost({
    this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.imagePath,
    required this.creationDate,
    });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'imagePath': imagePath,
      'description': description,
      'creationDate': creationDate.toIso8601String(),
    };
  }
}
