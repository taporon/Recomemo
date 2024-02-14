import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_record_app/data/tab_notifier.dart';
import 'package:study_record_app/post/post.dart';
import 'package:study_record_app/post/post_edit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/database_helper.dart';

class PostDetails extends ConsumerStatefulWidget {
  final BlogPost post;
  final int tabIndex;

  const PostDetails({Key? key,
    required this.post,
    required this.tabIndex}) :
        super(key: key);

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends ConsumerState<PostDetails> {
  late BlogPost currentPost;

  @override
  void initState() {
    super.initState();
    currentPost = widget.post;
  }

  void _editPost() async {
    // 編集ページへの遷移と結果の待機
    final updatedPost = await Navigator.of(context).push<BlogPost>(
      MaterialPageRoute(builder: (context) => EditPostPage(post: currentPost)),
    );

    // 編集された投稿で状態を更新
    if (updatedPost != null) {
      setState(() {
        currentPost = updatedPost;
      });
      ref.read(tabsProvider.notifier).updatePostInTab(widget.tabIndex, updatedPost);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post; // widget.post を直接使用

    void _deletePost() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('削除確認'),
            content: const Text('この投稿を削除してもよろしいですか？'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'キャンセル'),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  // データベースから投稿を削除
                  final result = await DatabaseHelper.instance.delete(post.id!);
                  if (result > 0) {
                    print('投稿が削除されました。ID: ${post.id}');
                    // State Notifier にリストから投稿を削除するよう通知
                    ref.read(tabsProvider.notifier).removePostFromTab(widget.tabIndex, post);
                    Navigator.pop(context); // ダイアログを閉じる
                    Navigator.pop(context); // 前の画面に戻る
                  } else {
                    print('投稿の削除に失敗しました。ID: ${post.id}');
                  }
                },
                child: const Text('削除'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Memo Dtails'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePost,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPost,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(currentPost.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final url = Uri.parse(currentPost.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('URLを開けませんでした: $url')),
                  );
                }
              },
              child: Text(currentPost.url, style: const TextStyle(color: Colors.blue)),
            ),
            SizedBox(height: 16),
            Text(currentPost.description),
            SizedBox(height: 16),
            if (currentPost.imagePaths.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: currentPost.imagePaths.length,
                  itemBuilder: (context, index) {
                    final path = currentPost.imagePaths[index];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog( // 画像を表示するダイアログ　背景色を透明に設定
                              backgroundColor: Colors.transparent,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Image.file(File(path), fit: BoxFit.contain),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.file(File(path)),
                      ),
                    );
                  },
                ),
              ),

          ],
        ),
      ),
    );
  }
}