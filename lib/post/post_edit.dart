import 'dart:io';

import 'package:RecoMemo/post/post.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/database_helper.dart';

class EditPostPage extends StatefulWidget {
  final BlogPost post;

  const EditPostPage({Key? key, required this.post}) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _url;
  late String _description;
  List<String> _imagePaths = []; // 画像パスのリスト
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 初期値を設定
    _title = widget.post.title;
    _url = widget.post.url;
    _description = widget.post.description;
    _imagePaths = List.from(widget.post.imagePaths);
    print('Received post id: ${widget.post.id}');
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    setState(() {
      _imagePaths.addAll(images.map((xFile) => xFile.path));
    });
    }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePaths.add(image.path);
      });
    }
  }

  void _removeImage(String path) {
    setState(() {
      _imagePaths.remove(path);
    });
  }

  Widget _buildImagePickerWidget() {
    return Row(
          children: _imagePaths.map((path) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: Image.file(File(path), width: 120, height: 120)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => _removeImage(path),
                ),
              ],
            );
          }).toList(),
    );
  } // 画像選択ウィジェット

  void _submitEdit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final editedPost = BlogPost(
        id: widget.post.id, // 既存のポストIDを保持
        title: _title,
        url: _url,
        imagePaths: _imagePaths,
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
          const SnackBar(
            content: Text('更新に失敗しました'),
          ),
        );
      }
    }
  } // 編集処理

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Memo'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitEdit, // 編集処理を実行
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: _title,
                        decoration: const InputDecoration(
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
                        onSaved: (value) => _url = value ?? '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: _description,
                        maxLines: 10,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: TextStyle(
                              fontSize: 16),
                          border: InputBorder.none,),
                        onSaved: (value) => _description = value ?? '',
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
                      child: _buildImagePickerWidget(),
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