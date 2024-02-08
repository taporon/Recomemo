import 'package:flutter/material.dart';
import 'package:study_record_app/post/post.dart';
import 'package:study_record_app/post/post_details.dart';

class PostSearchDelegate extends SearchDelegate<BlogPost?> {
  final List<BlogPost> posts;

  PostSearchDelegate(this.posts);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = posts.where((post) => post.title.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final post = results[index];
        return ListTile(
          title: Text(post.title),
          subtitle: Text(post.description),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostDetails(post: post, tabIndex: 0),
                )
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = posts.where((post) => post.title.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final post = suggestions[index];
        return ListTile(
          title: Text(post.title),
          subtitle: Text(post.description),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostDetails(post: post, tabIndex: 0),
                )
            );
          },
        );
      },
    );
  }
}
