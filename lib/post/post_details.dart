import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_record_app/data/tab_notifier.dart';
import 'package:study_record_app/post/post.dart';
import 'package:study_record_app/post/post_edit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/database_helper.dart';

class PostDetails extends ConsumerWidget {
  final BlogPost post;
  final int tabIndex;

  PostDetails({required this.post, required this.tabIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void _editPost() async {
      final updatedPost = await Navigator.of(context).push<BlogPost>(
        MaterialPageRoute(builder: (context) => EditPostPage(post: post)),
      );
      if (updatedPost != null) {
        ref.read(tabsProvider.notifier).updatePostInTab(tabIndex, updatedPost);
      }
    }

    void _deleteMemo(int id) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(post.title),
            content: const Text('このメモを削除してもよろしいですか？'),
            actions: <Widget>[
              TextButton(
                child: const Text('キャンセル'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('削除'),
                onPressed: () async {
                  if (post.id != null) {
                    await DatabaseHelper.instance.delete(post.id!);
                    Navigator.of(context).pop(); // ダイアログを閉じる
                    Navigator.of(context).pop(); // 詳細画面を閉じてリストに戻る
                  }
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editPost,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(post.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final url = Uri.parse(post.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('URLを開けませんでした: $url')),
                  );
                }
              },
              child: Text(post.url, style: const TextStyle(color: Colors.blue)),
            ),
            SizedBox(height: 16),
            Text(post.description),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _deleteMemo(post.id!),
        child: Icon(Icons.delete),
        tooltip: 'Delete Post',
      ),
    );
  }
}
