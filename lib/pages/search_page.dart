import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twitty/components/post.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              onPressed: _searchController.clear,
              icon: Icon(Icons.clear),
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
      body: _buildSearchBody(),
    );
  }

  Widget _buildSearchBody() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("User Posts")
          .orderBy("TimeStamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<DocumentSnapshot> filteredPosts =
              _getFilteredPosts(snapshot.data!.docs);
          return ListView.builder(
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];
              return Post(
                message: post['Message'],
                user: post['UserEmail'],
                postId: post.id,
                likes: List<String>.from(post['Likes'] ?? []),
                time: post['TimeStamp'],
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error:' + snapshot.error.toString()),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  List<DocumentSnapshot> _getFilteredPosts(List<DocumentSnapshot> posts) {
    final String searchQuery = _searchController.text.toLowerCase();
    return posts.where((post) {
      final String message = post['Message'].toString().toLowerCase();
      return message.contains(searchQuery);
    }).toList();
  }
}
