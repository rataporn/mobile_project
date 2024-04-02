import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ProfileImage(),
        Divider(color: Colors.black),
        ProfileDetails(),
      ]),
    ));
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 10),
      child: Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.blue[400]),
        padding: EdgeInsets.all(50),
        child: const Icon(Icons.person),
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user?.email}',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ),
          _buildDetailsRow(
              'He turned in the research paper on Friday; otherwise, he would have not passed the class.')
        ],
      ),
    );
  }
}

Widget _buildDetailsRow(String value) {
  return Row(
    children: [
      Flexible(
        child: Text(
          value,
          overflow: TextOverflow.visible,
        ),
      ),
    ],
  );
}
