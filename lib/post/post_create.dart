
import 'package:flutter/material.dart';
import 'package:study_record_app/post/post.dart';
import '../data/database_helper.dart';

class PostCreate extends StatefulWidget {
  final int currentTabIndex;
  final Function(BlogPost) onPostSubmit;

  const PostCreate({Key? key, required this.currentTabIndex, required this.onPostSubmit}) : super(key: key);

  @override
  State<PostCreate> createState() => _PostCreateState();
}

class _PostCreateState extends State<PostCreate> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _url = '';
  String _description = '';

  void _submitPost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newPost = BlogPost(
        title: _title,
        url: _url,
        description: _description,
        creationDate: DateTime.now(),
      );
      // データベースヘルパーを使用してデータを保存
      DatabaseHelper helper = DatabaseHelper.instance;
      int id = await helper.insert(newPost.toMap()); // toMap()はBlogPostをMapに変換
      newPost.id = id;
      print('挿入された行のID: $id');

      widget.onPostSubmit(newPost); // コールバックを呼び出す

      Navigator.of(context).pop(); // フォーム画面を閉じる
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Memo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _submitPost,  // 保存処理を実行
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Title',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        fontSize: 16,)
                      ),
                  onSaved: (value) => _title = value!,
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return 'タイトルは必須入力です';
                    }
                    return null;
                  }
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'URL',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(
                        fontSize: 16),
                        border: InputBorder.none,
                    ),
                    onSaved: (value) => _url = value!,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(
                          fontSize: 16),
                      border: InputBorder.none,
                  ),
                  onSaved: (value) => _description = value!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

