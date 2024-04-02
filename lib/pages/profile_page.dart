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
          SizedBox(height: 10),
          _buildFirestoreDataWidget(),
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
              return Profile(
                description: profile['Description'],
                user: profile.id,
                time: profile['TimeStamp'],
              );
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
}

class Profile extends StatelessWidget {
  final String description;
  final String user;
  final Timestamp time;

  const Profile({
    Key? key,
    required this.description,
    required this.user,
    required this.time,
  }) : super(key: key);

  void editDescription(
      BuildContext context, String currentDescription, String userId) {
    // Controller to handle the edited description
    TextEditingController _editedDescriptionController =
        TextEditingController(text: currentDescription);

    // Show a dialog with a text field for editing the description
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Description"),
        contentPadding: EdgeInsets.all(20.0),
        content: Container(
          width: 400.0, // Set the width as needed
          child: TextField(
            controller: _editedDescriptionController,
            maxLines: null, // Allow the TextField to expand vertically
            decoration: InputDecoration(hintText: "Edit your Description..."),
          ),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              // Dismiss the dialog
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),

          // Save changes button
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              // Perform the edit action
              if (_editedDescriptionController.text.isNotEmpty) {
                FirebaseFirestore.instance
                    .collection("User Details")
                    .doc(
                        userId) // Use userId to update the specific user's description
                    .update({
                  "Description": _editedDescriptionController.text,
                }).then((value) {
                  print("Description edited successfully");
                }).catchError((error) {
                  print("Failed to edit Description: $error");
                });
              }

              // Dismiss the dialog
              Navigator.pop(context);
            },
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(description),
      onTap: () => editDescription(context, description, user),
    );
  }
}
