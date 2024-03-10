// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitty/components/comment.dart';
import 'package:twitty/components/comment_button.dart';
import 'package:twitty/components/delete_button.dart';
import 'package:twitty/components/like_button.dart';
import 'package:twitty/helper/helper_methods.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final Timestamp time;

  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // coment text controller
  final _commentTextController = TextEditingController();
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // toggle Like
  void toggleLiked() {
    setState(() {
      isLiked = !isLiked;
    });

    //Access the Document is Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      // if the post is now liked, add the user email to Liked field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if the post is now unliked, remove the user email from Liked field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // add a comment
  void addComment(String commentText) {
    // write the comment to firestore under the comment this post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  // show a dialog box for add comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(hintText: "Write Comment.."),
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () {
              // pop box
              Navigator.pop(context);

              // clear controller
              _commentTextController.clear();
            },
            child: Text("Cancel"),
          ),

          // post button
          TextButton(
            onPressed: () {
              // add comment
              addComment(_commentTextController.text);

              // pop box
              Navigator.pop(context);

              // clear controller
              _commentTextController.clear();
            },
            child: Text("Post"),
          ),
        ],
      ),
    );
  }

  void deletePost() {
    // show a dialog box asking for confirmation brfore delete
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          // Delete Button
          TextButton(
            onPressed: () async {
              // delete the comment from firestore
              // if you only delete the post, the comment will store in firestore
              final commentDocs = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }
              // then delete the post
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("Post deleted"))
                  .catchError(
                      (error) => print("failed to delete post: $error"));

              // dissmiss the dialog
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.only(top: 25, left: 25, right: 25),
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // message and user email
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // profile pic
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue[400]),
                      padding: EdgeInsets.all(5),
                      child: const Icon(Icons.person),
                    ),
                    const SizedBox(width: 20),
                    // user
                    Expanded(
                      child: Text(
                        widget.user,
                        style: TextStyle(color: Colors.blue[500]),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatDate(widget.time),
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(width: 10),
                    if (widget.user == currentUser.email)
                      DeleteButton(onTap: deletePost)
                  ],
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 54,
                ),
                Expanded(
                  child: Text(
                    widget.message,
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Like Button
                LikeButton(
                  isLiked: isLiked,
                  onTap: toggleLiked,
                ),
                const SizedBox(
                  height: 5,
                ),
                // Like count
                Text(
                  widget.likes.length.toString(),
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(
                  width: 5,
                ),
                // comment
                CommentButton(onTap: showCommentDialog),
                const SizedBox(
                  width: 5,
                ),
                // comment count
                Text(
                  // widget.comments.length.toString(),
                  '3',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),

            // comments under post
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .orderBy("CommentTime")
                  .snapshots(),
              builder: (context, snapshot) {
                // show loading circle if no data yet
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    // get the comment
                    final commentData = doc.data() as Map<String, dynamic>;

                    //return the comment
                    // Check if the required properties are not null
                    if (commentData["CommentText"] != null &&
                        commentData["CommentTime"] != null &&
                        commentData["CommentedBy"] != null) {
                      return Comment(
                        text: commentData["CommentText"],
                        time: formatDate(commentData["CommentTime"]),
                        user: commentData["CommentedBy"],
                      );
                    } else {
                      // Handle the case where data is not as expected
                      return SizedBox(); // or any other appropriate widget or null
                    }
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
