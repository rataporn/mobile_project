// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  final VoidCallback onDelete;
  final String? currentUserEmail;

  const Comment({
    super.key,
    required this.text,
    required this.time,
    required this.user,
    required this.onDelete,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUserComment =
        currentUserEmail != null && user == currentUserEmail!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.only(bottom: 5, left: 50),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // user, time
          Row(
            children: [
              Expanded(
                child: Text(
                  user,
                  style: TextStyle(color: Colors.blue[500], fontSize: 12),
                ),
              ),
              Text("  "),
              Text(
                time,
                style: TextStyle(color: Colors.grey[700], fontSize: 10),
              ),
              SizedBox(
                width: 5,
              ),
              if (isCurrentUserComment)
                GestureDetector(
                  child: const Icon(
                    Icons.delete,
                    size: 15,
                    color: Colors.black,
                  ),
                  onTap: onDelete,
                ),
            ],
          ),
          // comment
          Text(text),
        ],
      ),
    );
  }
}
