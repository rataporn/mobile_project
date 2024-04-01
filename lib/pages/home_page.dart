// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twitty/components/post.dart';
import 'package:twitty/components/text_field.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();
  // sign out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  int selected = 0;
  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // post message
  void postMessage() {
    // only post if there is something in textfield
    if (textController.text.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    // clear the textfield
    setState(() {
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text(
          "The Twitty",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],
        actions: [
          // sign out button
          IconButton(
            onPressed: signOut,
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // the twitty
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get the message
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            // post message
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  // textfield
                  Expanded(
                    child: MyTextField(
                        controller: textController,
                        hintText: 'write something..',
                        obscureText: false),
                  ),

                  // post buton
                  IconButton(
                    onPressed: postMessage,
                    icon: Icon(Icons.arrow_circle_up),
                  )
                ],
              ),
            ),

            // logged in as
            Text(
              "Logged in as: " + currentUser.email!,
              style: TextStyle(color: Colors.blue),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),bottomNavigationBar: StylishBottomBar(
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
            selectedColor: Colors.teal,
            unSelectedColor: Colors.grey,
            title: const Text('Home'),
            // badge: const Text('9+'),
            showBadge: true,
            badgeColor: Color.fromARGB(255, 149, 105, 17),
            badgePadding: const EdgeInsets.only(left: 4, right: 4),
          ),
          BottomBarItem(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search_rounded),
            selectedColor: Color.fromARGB(255, 187, 116, 23),
            // unSelectedColor: Colors.purple,
            // backgroundColor: Colors.orange,
            title: const Text('Search'),
          ),
          BottomBarItem(
              icon: const Icon(
                Icons.person_outline,
              ),
              selectedIcon: const Icon(
                Icons.person,
              ),
              selectedColor: Colors.deepPurple,
              title: const Text('Profile')),
          BottomBarItem(
              icon: const Icon(
                Icons.settings_outlined
              ),
              selectedIcon: const Icon(
                Icons.settings,
              ),
              selectedColor: Colors.deepPurple,
              title: const Text('Setting')),
        ],
        hasNotch: true,
        fabLocation: StylishBarFabLocation.center,
        currentIndex: selected,
        notchStyle: NotchStyle.square,
        onTap: (index) {
          if (index == selected) return;
          controller.jumpToPage(index);
          setState(() {
            selected = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          // color: Colors.red,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
