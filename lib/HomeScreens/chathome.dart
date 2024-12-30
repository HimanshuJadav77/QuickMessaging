import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickmsg/HomeScreens/chatscreen.dart';
import 'package:quickmsg/Logins/showdialogs.dart';
import 'package:quickmsg/Ui/customcard.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

final currentUserId = FirebaseAuth.instance.currentUser!.uid;
final CollectionReference usersList = FirebaseFirestore.instance
    .collection("Users")
    .doc(currentUserId)
    .collection("chats");

class _ChatHomeState extends State<ChatHome> with TickerProviderStateMixin {
  List<bool> selectedStates = [];
  int indexSelected = 0;
  List<dynamic> selectedUserList = [];
  final Map<String, String> _users = {};

  @override
  void initState() {
    super.initState();
    // SocketService().onMessageReceived(
    //   (data) {
    //     setState(() {
    //       _users[data["sender"]] = data["message"];
    //     });
    //   },
    // );
  }

  deleteChat(selectedUserList) async {
    showMessageBox(
      "Deletion",
      "Are you want to delete this chats?",
      context,
      () {
        for (var userid in selectedUserList) {
          usersList.doc(userid).delete();
        }
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersList.where("chat", isEqualTo: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No Users Available For Chat."),
            );
          }

          final List<DocumentSnapshot> users =
              streamSnapshot.data!.docs.toList();
          if (selectedStates.length != users.length) {
            selectedStates = List.generate(
              users.length,
              (index) => false,
            );
          }
          int getSelectedStatesCount() {
            return selectedStates
                .where(
                  (isSelected) => isSelected,
                )
                .length;
          }

          return Scaffold(
            body: Column(
              children: [
                AnimatedContainer(
                  curve: Curves.easeInOut,
                  height: selectedStates.contains(true) ? 50 : 0,
                  duration: Duration(milliseconds: 500),
                  child: AppBar(
                    leading: IconButton(
                        tooltip: "Cancel",
                        onPressed: () {
                          setState(() {
                            selectedStates = List.generate(
                              users.length,
                              (index) {
                                return false;
                              },
                            );
                          });
                        },
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.blue,
                        )),
                    title: Text(
                      "${getSelectedStatesCount()} selected",
                      style: TextStyle(fontSize: 20),
                    ),
                    actions: [
                      IconButton(
                          tooltip: "Delete Selected Chats",
                          onPressed: () => deleteChat(selectedUserList),
                          icon: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                            size: 25,
                          ))
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot user = users[index];

                      if (selectedStates[index] == true) {
                        if (!selectedUserList.contains(user.id)) {
                          selectedUserList.add(user.id);
                        }
                      } else if (selectedStates[index] == false) {
                        if (selectedUserList.contains(user.id)) {
                          selectedUserList.remove(user.id);
                        }
                      }

                      return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection("Users")
                              .doc(user.id)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              final userData = snapshot.data!;
                              final preMessage = _users[userData["userid"]];

                              return Column(
                                children: [
                                  InkWell(
                                      onLongPress: () {
                                        setState(() {
                                          selectedStates[index] =
                                              !selectedStates[index];
                                        });
                                      },
                                      onTap: () {
                                        if (!selectedStates[index] &&
                                            !selectedStates.contains(true)) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                  imageurl:
                                                      userData["userimageurl"],
                                                  username:
                                                      userData["username"],
                                                  userid: userData["userid"],
                                                  about: userData["about"],
                                                  email: userData["email"],
                                                ),
                                              ));
                                        } else {
                                          setState(() {
                                            selectedStates[index] =
                                                !selectedStates[index];
                                          });
                                        }
                                      },
                                      child: Stack(
                                        children: [
                                          CustomCard(
                                            subtitle: Text(preMessage != null
                                                ? preMessage.toString()
                                                : ""),
                                            trailing: Text(""),
                                            username: userData["username"],
                                            imageurl: userData["userimageurl"],
                                            color: selectedStates[index]
                                                ? Colors.blue.shade50
                                                : Colors.white,
                                          ),
                                          selectedStates[index]
                                              ? Positioned(
                                                  left: 55,
                                                  bottom: 10,
                                                  child: CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor:
                                                        Colors.black,
                                                    child: Icon(
                                                      Icons.check_circle_sharp,
                                                      color: Colors.blueAccent,
                                                    ),
                                                  ),
                                                )
                                              : SizedBox.shrink(),
                                        ],
                                      )),
                                ],
                              );
                            }
                            return SizedBox.shrink();
                          });
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
