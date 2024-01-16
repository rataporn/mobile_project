// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  final String message;
  final String user;

  const Post({
    super.key,
    required this.message,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          // profile pic
          Container(
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.blue[400]),
            padding: EdgeInsets.all(10),
            child: const Icon(Icons.person),
          ),
          const SizedBox(width: 20),

          // message and user email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user,
                style: TextStyle(color: Colors.blue[500]),
              ),
              const SizedBox(height: 10),
              Text(message),
            ],
          ),
        ],
      ),
    );
  }
}
