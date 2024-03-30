// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final void Function()? onTap;
  const DeleteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: const Icon(
            Icons.cancel,
            size: 18,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Text('Delete Post')
      ],
    );
  }
}
