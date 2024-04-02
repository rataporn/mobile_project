import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitty/auth/auth.dart';
import 'package:twitty/components/post.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitty/components/post_modal.dart';
import 'package:twitty/pages/profile_page.dart';
import 'package:twitty/pages/setting_page.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // sign out
  void signOut() async {
    try {
      if (currentUser.providerData
          .any((userInfo) => userInfo.providerId == 'google.com')) {
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AuthPage()),
        );
      } else {
        FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  int selected = 0;

  Widget _getBodyWidget(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return _buildHomeBody();
      case 1:
        return Container();
      case 2:
        return ProfilePage();
      case 3:
        return SettingsPage();
      default:
        return Container();
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
                  fontWeight: FontWeight.bold),
            ),

            // sign out button
            GestureDetector(
              onTap: signOut,
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: _getBodyWidget(
          selected),
      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(
          iconSize: 32,
          barAnimation: BarAnimation.fade,
          iconStyle: IconStyle.animated,
          opacity: 0.3,
        ),
        items: [
          BottomBarItem(
            icon: const Icon(
              Icons.house_outlined,
            ),
            selectedIcon: const Icon(Icons.house_rounded),
            selectedColor: Colors.blue,
            unSelectedColor: Colors.grey,
            title: const Text('Home'),
          ),
          BottomBarItem(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search_rounded),
            selectedColor: Colors.blue,
            unSelectedColor: Colors.grey,
            title: const Text('Search'),
          ),
          BottomBarItem(
              icon: const Icon(
                Icons.person_outline,
              ),
              selectedIcon: const Icon(
                Icons.person,
              ),
              selectedColor: Colors.blue,
              unSelectedColor: Colors.grey,
              title: const Text('Profile')),
          BottomBarItem(
            icon: const Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: const Icon(
              Icons.settings,
            ),
            selectedColor: Colors.blue,
            unSelectedColor: Colors.grey,
            title: const Text('Setting'),
          ),
        ],
        hasNotch: true,
        fabLocation: StylishBarFabLocation.center,
        currentIndex: selected,
        notchStyle: NotchStyle.square,
        onTap: (index) {
          setState(() {
            selected = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => PostModal(),
          );
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomeBody() {
    return Stack(
      children: [
        Center(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .orderBy("TimeStamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data!.docs[index];
                    return Post(
                      message: post['Message'],
                      user: post['UserEmail'],
                      postId: post.id,
                      likes: List<String>.from(post['Likes'] ?? []),
                      time: post['TimeStamp'],
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error:' + snapshot.error.toString()),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }
}
