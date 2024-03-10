// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const EditButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: onTap,
    );
  }
}
