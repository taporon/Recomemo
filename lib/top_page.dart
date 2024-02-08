import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_record_app/post/post.dart';
import 'package:study_record_app/post/post_create.dart';
import 'package:study_record_app/data/tab_notifier.dart';

import 'data/database_helper.dart';
import 'data_search.dart';

class TopPage extends ConsumerStatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends ConsumerState<TopPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabsCount = ref.read(tabsProvider).tabs.length;
    _tabController = TabController(length: tabsCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabsState = ref.watch(tabsProvider);

    // タブの数が変わった場合にTabControllerを再構築
    if (_tabController.length != tabsState.tabs.length) {
      _tabController.dispose();
      _tabController = TabController(length: tabsState.tabs.length, vsync: this);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Keyword App'),
          actions: <Widget>[
            // AppBarのアクションに章を追加するボタンを設定
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => ref.read(tabsProvider.notifier).addTab(context), // ここでcontextを渡す
            ),

            IconButton(
              icon: Icon(Icons.search),
              onPressed: () async {
                // DatabaseHelperを使用して全投稿を取得
                final List<BlogPost> posts = await DatabaseHelper.instance.getAllPosts();
                showSearch(
                  context: context,
                  delegate: PostSearchDelegate(posts),
                );
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabsState.tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabsState.tabViews,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewPost(context),
        child: const Icon(Icons.edit_note),
      ),
    );
  }

  void _addNewPost(BuildContext context) {
    final tabIndex = _tabController.index;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostCreate(
          currentTabIndex: tabIndex,
          onPostSubmit: (newPost) {
            ref.read(tabsProvider.notifier).addPostToTab(tabIndex, newPost);
          },
        ),
      ),
    );
  }



}
