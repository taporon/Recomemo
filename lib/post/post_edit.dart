import 'package:flutter/material.dart';
import 'package:study_record_app/post/post.dart';

import '../data/database_helper.dart';

class EditPostPage extends StatefulWidget {
  final BlogPost post;

  EditPostPage({Key? key, required this.post}) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _url;
  late String _description;

  @override
  void initState() {
    super.initState();
    // 初期値を設定
    _title = widget.post.title;
    _url = widget.post.url;
    _description = widget.post.description;
    print('Received post id: ${widget.post.id}');
  }

  void _submitEdit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final editedPost = BlogPost(
        id: widget.post.id, // 既存のポストIDを保持
        title: _title,
        url: _url,
        description: _description,
        creationDate: widget.post.creationDate, // 既存の作成日を保持
      );
      print('Updating post with id: ${editedPost.id}');

      DatabaseHelper helper = DatabaseHelper.instance;
      int result = await helper.update(editedPost.toMap());

      if (result != 0) {
        // 成功した場合
        Navigator.of(context).pop(editedPost); // 編集されたポストを返す
      } else {
        // 失敗した場合
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Memo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitEdit, // 編集処理を実行
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
                  initialValue: _title,
                  decoration: InputDecoration(
                      labelText: 'Title',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        fontSize: 16,
                      )
                  ),
                  onSaved: (value) => _title = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'タイトルは必須入力です';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _url,
                  decoration: InputDecoration(
                    labelText: 'URL',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelStyle: TextStyle(
                        fontSize: 16),
                    border: InputBorder.none,
                  ),
                  onSaved: (value) => _url = value ?? '',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _description,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                      labelText: 'Description',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelStyle: TextStyle(
                        fontSize: 16),
                    border: InputBorder.none,),
                  onSaved: (value) => _description = value ?? '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
