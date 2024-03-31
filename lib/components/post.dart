// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers, avoid_print, use_build_context_synchronously, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitty/components/comment.dart';
import 'package:twitty/components/comment_button.dart';
import 'package:twitty/components/delete_button.dart';
import 'package:twitty/components/edit_button.dart';
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
  bool showFullMessage = false;

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
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),

          // post button
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              // add comment
              addComment(_commentTextController.text);

              // pop box
              Navigator.pop(context);

              // clear controller
              _commentTextController.clear();
            },
            child: Text(
              "Comment",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Delete Post
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
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),

          // Delete Button
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            ),
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
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  // Edit Post
  void editPost(String currentMessage) {
    // Controller to handle the edited post message
    TextEditingController _editedMessageController =
        TextEditingController(text: currentMessage);

    // Show a dialog with a text field for editing the post message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Post"),
        contentPadding: EdgeInsets.all(20.0),
        content: Container(
          width: 400.0, // Set the width as needed
          child: TextField(
            controller: _editedMessageController,
            maxLines: null, // Allow the TextField to expand vertically
            decoration: InputDecoration(hintText: "Edit your post..."),
          ),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              // Dismiss the dialog
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),

          // Save changes button
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              // Perform the post edit action
              // For example, update the post message in Firestore
              if (_editedMessageController.text.isNotEmpty) {
                FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .update({
                  "Message": _editedMessageController.text,
                }).then((value) {
                  print("Post edited successfully");
                }).catchError((error) {
                  print("Failed to edit post: $error");
                });
              }

              // Dismiss the dialog
              Navigator.pop(context);
            },
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Delete Comment
  void deleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Comment"),
        content: Text("Are you sure you want to delete this comment?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
          // Delete button
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            ),
            onPressed: () {
              // Delete the comment
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .doc(commentId)
                  .delete()
                  .then((value) {
                print("Comment deleted");
              }).catchError((error) {
                print("Failed to delete comment: $error");
              });
              Navigator.pop(context); // Close the dialog
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
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
        margin: EdgeInsets.only(top: 25, left: 20, right: 20),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // message and user email
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        style: TextStyle(color: Colors.blue[500], fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatDate(widget.time),
                      style: TextStyle(color: Colors.grey[500], fontSize: 9),
                    ),
                    if (widget.user == currentUser.email)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_outlined,
                          color: Colors.blue,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                              value: 'edit',
                              child: EditButton(
                                onTap: () {},
                              )),
                          PopupMenuItem(
                              value: 'delete',
                              child: DeleteButton(
                                onTap: () {},
                              )),
                        ],
                        onSelected: (String value) {
                          if (value == 'edit') {
                            editPost(widget.message);
                          } else if (value == 'delete') {
                            deletePost();
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 54,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.message.length > 120 && !showFullMessage
                            ? widget.message.substring(0, 120) + '...'
                            : widget.message,
                      ),
                      if (widget.message.length > 120)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // Toggle the state to show or hide the full message
                              showFullMessage = !showFullMessage;
                            });
                          },
                          child: Text(
                            showFullMessage ? 'Show Less' : 'Show More',
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
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
                      return Text(
                        '0', // Default to 0 if no comments yet
                        style: TextStyle(color: Colors.grey),
                      );
                    }

                    return Text(
                      snapshot.data!.docs.length.toString(),
                      style: TextStyle(color: Colors.grey),
                    );
                  },
                ),
              ],
            ),
            SizedBox(
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
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final List<DocumentSnapshot> comments = snapshot.data!.docs;

                // Extract first 3 comments
                List<Widget> initialComments = [];
                int commentsToShow = comments.length >= 3 ? 3 : comments.length;

                for (int i = 0; i < commentsToShow; i++) {
                  final commentData =
                      comments[i].data() as Map<String, dynamic>;

                  // Check if the required properties are not null
                  if (commentData["CommentText"] != null &&
                      commentData["CommentTime"] != null &&
                      commentData["CommentedBy"] != null) {
                    initialComments.add(
                      Comment(
                        text: commentData["CommentText"],
                        time: formatDate(commentData["CommentTime"]),
                        user: commentData["CommentedBy"],
                        currentUserEmail: currentUser.email ?? '',
                        onDelete: () {
                          deleteComment(comments[i].id);
                        },
                      ),
                    );
                  } else {
                    // Handle the case where data is not as expected
                    initialComments.add(
                        SizedBox()); // or any other appropriate widget or null
                  }
                }

                // Extract remaining comments for the ExpansionTile
                List<Widget> remainingComments = [];
                for (int i = 3; i < comments.length; i++) {
                  final commentData =
                      comments[i].data() as Map<String, dynamic>;

                  // Check if the required properties are not null
                  if (commentData["CommentText"] != null &&
                      commentData["CommentTime"] != null &&
                      commentData["CommentedBy"] != null) {
                    remainingComments.add(
                      Comment(
                        text: commentData["CommentText"],
                        time: formatDate(commentData["CommentTime"]),
                        user: commentData["CommentedBy"],
                        currentUserEmail: currentUser.email ?? '',
                        onDelete: () {
                          deleteComment(comments[i].id);
                        },
                      ),
                    );
                  } else {
                    // Handle the case where data is not as expected
                    remainingComments.add(
                        SizedBox()); // or any other appropriate widget or null
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Display first 3 comments outside the ExpansionTile
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: initialComments,
                    ),
                    if (comments.length > 3)
                      // Show ExpansionTile if there are more than 3 comments
                      ExpansionTile(
                        title: Text(
                          'Show all comments',
                          style: TextStyle(fontSize: 12),
                        ),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: remainingComments,
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
