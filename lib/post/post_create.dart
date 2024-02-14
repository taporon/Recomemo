
import 'dart:io';

import 'package:RecoMemo/post/post.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final List<XFile> _images = []; // 選択した写真のリスト

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedImages = await picker.pickMultiImage();// 複数の写真を選択// カメラを起動


    if (_images.length + selectedImages.length > 3) {
      // 選択枚数が3枚を超える場合にSnackBarを表示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('これ以上登録できません。')),
      );
    } else {
      setState(() {
        _images.addAll(selectedImages);
      });
    }
    }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera); // カメラを起動

    if (image != null) {
      if (_images.length >= 3) {
        // すでに3枚の写真が選択されている場合にSnackBarを表示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('これ以上登録できません。')),
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
      List<String> imagePaths = _images.map((xFile) => xFile.path).toList();


      final newPost = BlogPost(
        title: _title,
        url: _url,
        description: _description,
        imagePaths: imagePaths,
        creationDate: DateTime.now(),
      );
      // データベースヘルパーを使用してデータを保存
      int id = await DatabaseHelper.instance.insert(newPost);// toMap()はBlogPostをMapに変換
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
            icon: const Icon(Icons.check),
            onPressed: _submitPost,  // 保存処理を実行
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                            decoration: const InputDecoration(
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
                        validator: (value) {
                          // 入力がある場合のみURLの形式を検証
                          if (value != null && value.isNotEmpty && !Uri.parse(value).isAbsolute) {
                            return '有効なURLを入力してください';
                          }
                          return null; // 入力がない、または問題がない場合はnullを返してバリデーションを通過
                        },
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
                            icon: const Icon(Icons.camera_alt),
                            onPressed: _pickImageFromCamera, // 写真選択
                          ),
                          IconButton(
                            icon: const Icon(Icons.photo_library),
                            onPressed: _pickImage, // 写真選択
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _images.map((file) {
                          return Stack(
                            alignment: Alignment.center, // Stack内の子ウィジェットを中央に配置
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5), // 画像間のマージン
                                child: Image.file(File(file.path), width: 120, height: 120),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 30), // 赤色のキャンセルアイコン、サイズ調整可
                                onPressed: () {
                                  setState(() {
                                    _images.removeWhere((XFile img) => img.path == file.path); // この画像をリストから削除
                                  });
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}