import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twitty/components/post.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  //late DateTime? _selectedDate;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedDate = null;
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
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: _searchController.clear,
              icon: Icon(Icons.clear),
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        actions: [
          IconButton(
            onPressed: () => _selectDate(context),
            icon: Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: _buildSearchBody(),
    );
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
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
      final Timestamp? timeStamp = post['TimeStamp'];
      final DateTime? postDate = timeStamp?.toDate();
      bool messageContainsQuery = message.contains(searchQuery);
      bool dateMatches = postDate != null &&
          postDate.month == _selectedDate?.month &&
          postDate.day == _selectedDate?.day;
      return message.contains(searchQuery);
    }).toList();
  }
}
