import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_record_app/post/post.dart';
import 'package:study_record_app/post/post_details.dart';

class TabsState {
  final List<Widget> tabs;
  final List<Widget> tabViews;

  TabsState({required this.tabs, required this.tabViews});
}

final tabsProvider = StateNotifierProvider<TabsNotifier, TabsState>((ref) {
  return TabsNotifier();
});


class TabsNotifier extends StateNotifier<TabsState> {

  final List<List<BlogPost>> postsLists = [
    [], // 第1章の投稿リスト
    [], // 第2章の投稿リスト
    [], // 第3章の投稿リスト
  ];

  TabsNotifier()
      : super(TabsState(
    tabs: [
      const Tab(text: '第1章'),
      const Tab(text: '第2章'),
      const Tab(text: '第3章'),
    ],
    tabViews: [])) {
    _initializeTabViews();
    }
  void removePostFromTab(int tabIndex, BlogPost post) {
    // 特定のタブのリストから投稿を削除
    postsLists[tabIndex].removeWhere((item) => item.id == post.id);
    // UIをリフレッシュ
    _refreshTabViews();
  }

  void updatePostInTab(int tabIndex, BlogPost updatedPost) {
    var posts = postsLists[tabIndex];
    var index = posts.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      posts[index] = updatedPost;
      // UIをリフレッシュ
      _refreshTabViews();
    }
  }

  void _refreshTabViews() {
    List<Widget> updatedTabViews = [];
    for (int i = 0; i < postsLists.length; i++) {
      updatedTabViews.add(_buildListView(i));
    }
    state = TabsState(tabs: List.from(state.tabs), tabViews: updatedTabViews);
  }

  void _initializeTabViews() {
    List<Widget> initialTabViews = [];
    for (int i = 0; i < postsLists.length; i++) {
      initialTabViews.add(_buildListView(i));
    }
    state = TabsState(tabs: List.from(state.tabs), tabViews: initialTabViews);
  }

  Widget _buildListView(int tabIndex) {
    final posts = List<BlogPost>.from(postsLists[tabIndex]);

    // 日付でソート（新しいものから古いものへ）
    posts.sort((a, b) => b.creationDate.compareTo(a.creationDate));


    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final formattedDate = DateFormat('yyyy/MM/dd').format(post.creationDate);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                     post.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      post.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey, fontSize: 12
                ),
              ),
            ],
          ),
            onTap: (){
              Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PostDetails(post: post, tabIndex: tabIndex),
                  )
              );
             },
            ),
          );
        },
      );
    }

  void addPostToTab(int tabIndex, BlogPost post) {
    postsLists[tabIndex].add(post);
    state = TabsState(
      tabs: List.from(state.tabs),
      tabViews: [
        for (int i = 0; i < state.tabs.length; i++) _buildListView(i),
      ],
    );
  }

  // TabsNotifier内
  // TabsNotifierクラス内

  void addTab(BuildContext context) {
    if (postsLists.length >= 15) {
      // 15章以上の場合はSnackBarを表示して追加を拒否
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('章は最大15までです。これ以上は追加できません。')),
      );
    } else {
      // 新しい章（タブ）を追加
      postsLists.add([]); // 新しい章の投稿リストを追加
      var newTabs = List<Tab>.from(state.tabs)
        ..add(Tab(text: '第${postsLists.length}章'));
      var newTabViews = List<Widget>.from(state.tabViews)
        ..add(_buildListView(postsLists.length - 1));
      state = TabsState(tabs: newTabs, tabViews: newTabViews);
    }
  }

  void removeTab(int tabIndex) {
    postsLists.removeAt(tabIndex); // 指定された章の投稿リストを削除
    var newTabs = List<Tab>.from(state.tabs)..removeAt(tabIndex);
    var newTabViews = List<Widget>.from(state.tabViews)..removeAt(tabIndex);
    state = TabsState(tabs: newTabs, tabViews: newTabViews);
  }

}