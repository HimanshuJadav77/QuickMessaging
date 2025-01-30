import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickmsg/HomeScreens/chathome.dart';
import 'package:quickmsg/HomeScreens/chatscreen.dart';
import 'package:quickmsg/HomeScreens/searchuser.dart';
import 'package:quickmsg/Ui/customcard.dart';
import 'package:quickmsg/Ui/elvb.dart';

class FollowedChatList extends StatefulWidget {
  const FollowedChatList({super.key});

  @override
  State<FollowedChatList> createState() => _FollowedChatListState();
}

class _FollowedChatListState extends State<FollowedChatList> {
  @override
  Widget build(BuildContext context) {
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
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUserId)
            .collection("following")
            .where("following", isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final usersList = snapshot.data!.docs.toList();
          if (!snapshot.hasData || usersList.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text("No user for chatting follow first"),
                ),
                Elvb(
                    onpressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchUser(),
                          ));
                    },
                    name: "Search Users",
                    foregroundcolor: Colors.white,
                    backgroundcolor: Colors.blue)
              ],
            );
          }
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
                        subtitle: Center(),
                        color: Colors.white,
                        username: userData["username"],
                        imageurl: userData["userimageurl"],
                        trailing: Text(""),
                      ),
                    );
                  });
            },
          );
        },
      ),
    );
  }
}
