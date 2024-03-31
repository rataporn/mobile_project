import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitty/components/text_field.dart';
import 'package:flutter/material.dart';

class PostModal extends StatefulWidget {
  const PostModal({super.key});

  @override
  State<PostModal> createState() => _PostModalState();
}

class _PostModalState extends State<PostModal> {
  // text controller
  final textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  // post message
  void postMessage() {
    // only post if there is something in textfield
    if (textController.text.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    // clear the textfield
    setState(() {
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(
            children: [
              // textfield
              Expanded(
                child: MyTextField(
                  controller: textController,
                  hintText: 'write something..',
                  obscureText: false,
                ),
              ),

              // post button
              IconButton(
                onPressed: postMessage,
                icon: Icon(Icons.arrow_circle_up),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
