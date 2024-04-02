import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Profile Settings'),
            onTap: () {
              // Navigate to profile settings page
            },
          ),
          ListTile(
            title: Text('Ban word'),
            onTap: () {
              // Navigate to notification settings page
            },
          ),
          ListTile(
            title: Text('Log out'),
            onTap: () {
              // Navigate to privacy settings page
            },
          ),
          ListTile(
            title: Text('Delete account'),
            onTap: () {
              // Navigate to about page
            },
          ),
          // Add more settings options as needed
        ],
      ),
    );
  }
}
