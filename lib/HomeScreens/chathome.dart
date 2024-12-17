import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickmsg/HomeScreens/chatscreen.dart';
import 'package:quickmsg/Ui/customcard.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

final CollectionReference usersList =
    FirebaseFirestore.instance.collection("Users");

class _ChatHomeState extends State<ChatHome> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersList.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final List<DocumentSnapshot> users =
                streamSnapshot.data!.docs.toList();
            final currentUserid = FirebaseAuth.instance.currentUser!.uid;
            final usersList = users.where((user) {
              return user["userid"] != currentUserid;
            }).toList();

            return Scaffold(
              body: ListView.builder(
                itemCount: usersList.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot userData = usersList[index];
                  return Column(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    imageurl: userData["userimageurl"],
                                    username: userData["username"],
                                    userid: userData["userid"],
                                  ),
                                ));
                          },
                          child: CustomCard(
                            username: userData["username"],
                            imageurl: userData["userimageurl"],
                            userid: userData["userid"],
                          )),
                    ],
                  );
                },
              ),
            );
          }
          return const Center();
        });
  }
}
