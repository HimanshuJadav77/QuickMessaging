import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickmsg/HomeScreens/Profile/seachuserprofile.dart';
import 'package:quickmsg/HomeScreens/chatscreen.dart';
import '../Logins/showdialogs.dart';
import '../Ui/customcard.dart';
import 'chathome.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  final searchC = TextEditingController();
  bool blocked = false;
  final CollectionReference usersList =
      FirebaseFirestore.instance.collection("Users");

  blockUser(blockUserid) {
    if (blocked) {
      FirebaseFirestore.instance
          .collection("block")
          .doc(currentUserId)
          .collection("blockedid")
          .doc(blockUserid)
          .set({"blocked": false});
      setState(() {
        blocked = false;
      });
    } else {
      FirebaseFirestore.instance
          .collection("block")
          .doc(currentUserId)
          .collection("blockedid")
          .doc(blockUserid)
          .set({"blocked": true});
      setState(() {
        blocked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: const Text(
          'Search Users',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search TextField
          Padding(
            padding:
                const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 5),
            child: TextField(
              controller: searchC, // Bind TextField to the controller
              onChanged: (value) {
                setState(() {}); // Rebuild when search query changes
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_search_outlined),
                labelText: "Search",
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const Divider(),

          Expanded(
            child: StreamBuilder(
              stream: usersList.snapshots(), // Get all users
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator()); // Loading state
                }

                if (streamSnapshot.hasError) {
                  return Center(child: Text('Error: ${streamSnapshot.error}'));
                }

                if (streamSnapshot.hasData) {
                  final List<DocumentSnapshot> users =
                      streamSnapshot.data!.docs;
                  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

                  if (searchC.text.isEmpty) {
                    return const Center(child: Text("Please type to search."));
                  }

                  final filteredUsers = users.where((user) {
                    final username = user["username"]
                        .toString()
                        .toLowerCase()
                        .replaceAll(RegExp(r'\s+'), '');
                    final searchQuery = searchC.text.toLowerCase();

                    return username.contains(searchQuery) &&
                        user["userid"] != currentUserId;
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot userData = filteredUsers[index];

                      final inkwell = GlobalKey();
                      return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("block")
                              .doc(currentUserId)
                              .collection("blockedid")
                              .doc(userData["userid"])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {}
                            final blockdata = snapshot.data?.data();
                            final block = blockdata?["blocked"];
                            return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("block")
                                    .doc(userData["userid"])
                                    .collection("blockedid")
                                    .doc(currentUserId)
                                    .snapshots(),
                                builder: (context, bsnapshot) {
                                  if (bsnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center();
                                  }
                                  if (!bsnapshot.hasData ||
                                      bsnapshot.data?.data()?["blocked"] ==
                                          true) {
                                    return Center();
                                  }
                                  if (bsnapshot.data!.data() == null ||
                                      bsnapshot.data!.data()!["blocked"] ==
                                          false) {
                                    return InkWell(
                                      key: inkwell,
                                      onTap: () {
                                        final RenderBox renderbox = inkwell
                                            .currentContext!
                                            .findRenderObject() as RenderBox;
                                        final position = renderbox
                                            .localToGlobal(Offset.zero);
                                        showMenu(
                                          color: Colors.white,
                                          elevation: 10,
                                          shadowColor: Colors.black54,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          context: context,
                                          position: RelativeRect.fromLTRB(
                                              position.dx + 200,
                                              position.dy + 30,
                                              position.dx + 400,
                                              position.dy + 100),
                                          items: [
                                            PopupMenuItem<String>(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.message_outlined,
                                                    size: 20,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  const Text('Message'),
                                                ],
                                              ),
                                              onTap: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatScreen(
                                                      username:
                                                          userData["username"],
                                                      email: userData["email"],
                                                      about: userData["about"],
                                                      imageurl: userData[
                                                          "userimageurl"],
                                                      userid:
                                                          userData["userid"],
                                                    ),
                                                  ),
                                                );

                                                await FirebaseFirestore.instance
                                                    .collection("Users")
                                                    .doc(currentUserId)
                                                    .collection("chats")
                                                    .doc(userData["userid"])
                                                    .set({
                                                  "chat": true,
                                                  "time": FieldValue
                                                      .serverTimestamp()
                                                });
                                              },
                                            ),
                                            PopupMenuItem<String>(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .account_circle_outlined,
                                                    size: 20,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  const Text('Profile'),
                                                ],
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SearchUserProfile(
                                                      username:
                                                          userData["username"],
                                                      email: userData["email"],
                                                      about: userData["about"],
                                                      imageurl: userData[
                                                          "userimageurl"],
                                                      userid:
                                                          userData["userid"],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            PopupMenuItem<String>(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.block,
                                                    size: 20,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    block == true
                                                        ? "Unblock"
                                                        : 'Block',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                showMessageBox(
                                                    block ? "Unblock" : "Block",
                                                    block
                                                        ? "Are you sure to Unblock ${userData["username"]}?"
                                                        : "Are you sure to block ${userData["username"]}?",
                                                    context,
                                                    block ? "Unblock" : "Block",
                                                    () {
                                                  blockUser(userData["userid"]);
                                                  Navigator.pop(context);
                                                });
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                      child: CustomCard(
                                        subtitle: Center(),
                                        username: userData["username"],
                                        imageurl: userData["userimageurl"],
                                        color: Colors.white,
                                        trailing: Text(""),
                                      ),
                                    );
                                  }
                                  return Center();
                                });
                          });
                    },
                  );
                }

                return const Center(child: Text("No Users Found"));
              },
            ),
          )
        ],
      ),
    );
  }
}
