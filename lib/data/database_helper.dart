import 'dart:convert';

import 'package:RecoMemo/post/post.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';



class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 15;
  static const table = 'my_table';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnUrl = 'url';
  static const columnDate = 'creationDate';

  // データベースヘルパーをシングルトンにする
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // データベースの初期化
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // データベースを開く
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // バージョン14から15へのアップグレード時に実行される処理
    if (oldVersion < 15) {
      await db.execute('ALTER TABLE $table ADD COLUMN imagePaths TEXT');
    }
  }


  // データベースの作成
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
      $columnId INTEGER PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnDescription TEXT NOT NULL,
      $columnUrl TEXT NOT NULL,
      $columnDate TEXT NOT NULL,
      imagePaths TEXT
    )
  ''');
  }

  // データの挿入
  Future<int> insert(BlogPost post) async {
    Database db = await database;
    Map<String, dynamic> row = post.toMap(); // BlogPostからマップを取得
    return await db.insert(table, row);
  }

  // データの取得
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // データの更新
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  // データの削除
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<List<BlogPost>> getAllPosts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);

    return List.generate(maps.length, (i) {
      // JSON 文字列をデコードしてリストに変換、nullまたは空文字列の場合は空のリストを使用
      List<String> imagePaths = [];
      if (maps[i]['imagePaths'] != null && maps[i]['imagePaths'].isNotEmpty) {
        imagePaths = List<String>.from(jsonDecode(maps[i]['imagePaths']));
      }

      return BlogPost(
        id: maps[i]['id'] as int?,
        title: maps[i]['title'] as String,
        description: maps[i]['description'] as String,
        url: maps[i]['url'] as String,
        imagePaths: imagePaths,
        creationDate: DateTime.parse(maps[i]['creationDate'] as String),
      );
    });
  }

  Future<String> saveImageLocally(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName = basename(image.path);
    final File localImage = File('$path/$fileName');
    await localImage.writeAsBytes(await image.readAsBytes());

    return localImage.path;
  }
}