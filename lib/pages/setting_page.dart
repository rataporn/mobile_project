import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitty/auth/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'profile_setting_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  void signOut() async {
    try {
      if (currentUser.providerData
          .any((userInfo) => userInfo.providerId == 'google.com')) {
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthPage()),
        );
      } else {
        FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void deleteAccount() async {
    try {
      await currentUser?.delete();
    } catch (e) {
      print('Failed to delete account: $e');
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),),
      ),
      body: Material(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Profile Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileSettingPage(
                          currentUser:
                              currentUser)),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('Log out',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),),
              onTap: () {
                signOut();
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Delete account',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                deleteAccount();
              },
            ),
          ],
        ),
      ),
    );
  }
}
