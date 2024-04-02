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
            Icons.delete,
            size: 18,
            color: Colors.red,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          'Delete',
          style: TextStyle(color: Colors.red),
        )
      ],
    );
  }
}
