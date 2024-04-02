import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileImage(),
            SizedBox(
              height: 10,
            ),
            Divider(color: Colors.black),
            ProfileDetails(),
          ],
        ),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20, left: 10),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[400],
                ),
                padding: EdgeInsets.all(20),
                child: const Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({Key? key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user?.email}',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20),
          _buildFirestoreDataWidget(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFirestoreDataWidget() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("User Details").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final profile = snapshot.data!.docs[index];
              return _buildDetailsRow(profile['Description']);
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error.toString()}'),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget _buildDetailsRow(String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}
