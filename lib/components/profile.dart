import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final String description;
  final String user;
  final Timestamp time;

  const Profile({
    super.key,
    required this.description,
    required this.user,
    required this.time,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
