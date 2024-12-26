import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickmsg/HomeScreens/chatscreen.dart';
import 'package:quickmsg/Ui/customcard.dart';

class FollowedChatList extends StatefulWidget {
  const FollowedChatList({super.key});

  @override
  State<FollowedChatList> createState() => _FollowedChatListState();
}

class _FollowedChatListState extends State<FollowedChatList> {
  @override
  Widget build(BuildContext context) {
    final userid = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance
        .collection("Users")
        .doc(userid)
        .collection("following");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Chat",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
      ),
      body: StreamBuilder(
        stream: firestore.where("following", isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final usersList = snapshot.data!.docs.toList();
          return ListView.builder(
            itemCount: usersList.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("Users")
                      .doc(usersList[index].id)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final userData = userSnapshot.data!;
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                imageurl: userData["userimageurl"],
                                username: userData["username"],
                                userid: usersList[index].id,
                                about: userData["about"],
                                email: userData["email"],
                              ),
                            ));
                      },
                      child: CustomCard(
                        subtitle: "",
                          color: Colors.white,
                          username: userData["username"],
                          imageurl: userData["userimageurl"], trailing: Text(""),),
                    );
                  });
            },
          );
        },
      ),
    );
  }
}
