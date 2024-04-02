import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitty/auth/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileSettingPage extends StatelessWidget {
  final User currentUser;

  const ProfileSettingPage({Key? key, required this.currentUser})
      : super(key: key);

  Future<void> _showErrorDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeEmail(BuildContext context) async {
    try {
      String? newEmail;

      await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Change Email'),
            content: TextFormField(
              onChanged: (value) {
                newEmail = value.trim();
              },
              decoration: InputDecoration(
                hintText: 'Enter new email',
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Change'),
                onPressed: () async {
                  if (newEmail == null || newEmail!.isEmpty) {
                    _showErrorDialog(context, 'Please enter a new email.');
                    return;
                  }

                  try {
                    await currentUser.updateEmail(newEmail!);
                    Navigator.of(context).pop();
                    _showErrorDialog(context, 'Email changed successfully');
                  } catch (e) {
                    print('Failed to change email: $e');
                    _showErrorDialog(context, 'Failed to change email: $e');
                  }
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error: $e');
      _showErrorDialog(context, 'An error occurred: $e');
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    try {
      String? oldPassword;
      String? newPassword;

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  onChanged: (value) {
                    oldPassword = value.trim();
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter old password',
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  onChanged: (value) {
                    newPassword = value.trim();
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Change'),
                onPressed: () async {
                  if (oldPassword == null || oldPassword!.isEmpty) {
                    _showErrorDialog(
                        context, 'Please enter your old password.');
                    return;
                  }
                  if (newPassword == null || newPassword!.isEmpty) {
                    _showErrorDialog(context, 'Please enter a new password.');
                    return;
                  }

                  try {
                    AuthCredential credential = EmailAuthProvider.credential(
                        email: currentUser.email!, password: oldPassword!);
                    await currentUser.reauthenticateWithCredential(credential);

                    await currentUser.updatePassword(newPassword!);
                    Navigator.of(context).pop();
                    _showErrorDialog(context, 'Password changed successfully');
                  } catch (e) {
                    print('Failed to change password: $e');
                    _showErrorDialog(context, 'Failed to change password: $e');
                  }
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error: $e');
      _showErrorDialog(context, 'An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[500],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Twitty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Material(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Email: ${currentUser.email}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Change Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                _changeEmail(context);
              },
            ),
            ListTile(
              title: Text(
                'Change Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                _changePassword(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
