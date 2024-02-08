
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  //イメージピッカーを使用して写真を選択
  List<XFile> _images = []; // 選択した写真のリスト

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();// 複数の写真を選択// カメラを起動


    if (selectedImages != null) {
      if (_images.length + selectedImages.length > 3) {
        // 選択枚数が3枚を超える場合にSnackBarを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('これ以上登録できません。')),
        );
      } else {
        setState(() {
          _images.addAll(selectedImages);
        });
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera); // カメラを起動

    if (image != null) {
      if (_images.length >= 3) {
        // すでに3枚の写真が選択されている場合にSnackBarを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('これ以上登録できません。')),
        );
      } else {
        setState(() {
          _images.add(image);
        });
      }
    }
  }


  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _url = '';
  String _description = '';

  void _submitPost() async {

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String imagePath = '';
      if (_images.isNotEmpty) {
        // 選択された最初の画像をローカルに保存し、そのパスを取得
        imagePath = await DatabaseHelper.instance.saveImageLocally(_images.first);
      }

      final newPost = BlogPost(
        title: _title,
        url: _url,
        description: _description,
        imagePath: imagePath,
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
      body: Column(
        children: [
          Form(
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: _pickImageFromCamera, // 写真選択
                        ),
                        IconButton(
                          icon: Icon(Icons.photo_library),
                          onPressed: _pickImage, // 写真選択
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        // 写真表示
                        Wrap(
                          children: _images.map((file) => Image.file(File(file.path), width: 100, height: 100)).toList(),
                        ),
                        // 投稿フォーム...
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

