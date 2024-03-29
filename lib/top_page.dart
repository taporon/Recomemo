import 'package:RecoMemo/post/post.dart';
import 'package:RecoMemo/post/post_create.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

import 'data/database_helper.dart';
import 'data/tab_notifier.dart';
import 'data_search.dart';

class TopPage extends ConsumerStatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends ConsumerState<TopPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();


  @override
  void initState() {
    super.initState();
    final tabsCount = ref.read(tabsProvider).tabs.length;
    _tabController = TabController(length: tabsCount, vsync: this);
    // ウィジェットのビルドが完了した後にチュートリアルを開始する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // チュートリアルを開始するメソッドを呼び出す
      ShowCaseWidget.of(context).startShowCase([_one, _two, _three]);
    });
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
        title: const Text('RecoMemo'),
        actions: <Widget>[
          // AppBarのアクションに章を追加するボタンを設定
          Showcase(
            key: _two,
            title: 'タブの追加',titleTextStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            description: 'Chapterを追加できます（最大Chapter15まで）',
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => ref.read(tabsProvider.notifier).addTab(context), // ここでcontextを渡す
            ),
          ),

          Showcase(
            key: _three,
            title: '検索',titleTextStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            description: '投稿を検索できます',
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                // DatabaseHelperを使用して全投稿を取得
                final List<BlogPost> posts = await DatabaseHelper.instance.getAllPosts();
                showSearch(
                  context: context,
                  delegate: PostSearchDelegate(posts),
                );
              },
            ),
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
      floatingActionButton:
      Showcase(
        key: _one,
        title: '新規投稿',titleTextStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        description: '新しい投稿を追加できます',
        child: FloatingActionButton(
          onPressed: () => _addNewPost(context),
          child: const Icon(Icons.edit_note),
        ),
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