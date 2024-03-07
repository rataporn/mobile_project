// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;

  const Comment({
    super.key,
    required this.text,
    required this.time,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
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
            ],
          ),
          // comment
          Text(text),
        ],
      ),
    );
  }
}
