import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const EditButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: const Icon(
            Icons.edit,
            size: 18,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          'Edit',
          style: TextStyle(
            color: Colors.blue,
          ),
        )
      ],
    );
  }
}
