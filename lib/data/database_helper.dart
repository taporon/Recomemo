import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:study_record_app/post/post.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 14;
  static final table = 'my_table';
  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnDescription = 'description';
  static final columnUrl = 'url';
  static final columnDate = 'creationDate';

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
        onCreate: _onCreate);
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
      imagePath TEXT 
    )
  ''');
  }

  // データの挿入
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('my_table', row);
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

  // DatabaseHelperクラス内に追加
  Future<List<BlogPost>> getAllPosts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);

    return List.generate(maps.length, (i) {
      return BlogPost(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        url: maps[i]['url'],
        imagePath: maps[i]['imagePath'],
        creationDate: DateTime.parse(maps[i]['creationDate']),
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
