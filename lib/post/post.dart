import 'dart:convert';

class BlogPost {
  int? id;
  final String title;
  final String description;
  final String url;
  List<String> imagePaths; // List<String> として定義
  final DateTime creationDate;

  BlogPost({
    this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.imagePaths,
    required this.creationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'imagePaths': jsonEncode(imagePaths),
      'creationDate': creationDate.toIso8601String(),
    };
  }

  // JSON 文字列から BlogPost オブジェクトを生成するファクトリコンストラクタ
  factory BlogPost.fromMap(Map<String, dynamic> map) {
    return BlogPost(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      url: map['url'],
      imagePaths: jsonDecode(map['imagePaths']),
      creationDate: DateTime.parse(map['creationDate']),
    );
  }
}
