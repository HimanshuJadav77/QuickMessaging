import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickmsg/HomeScreens/Profile/seachuserprofile.dart';
import 'package:quickmsg/HomeScreens/chatscreen.dart';
import '../Ui/customcard.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  final searchC = TextEditingController();
  final CollectionReference usersList =
      FirebaseFirestore.instance.collection("Users");

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
                    final username = user["username"].toLowerCase();
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
                      final _inkwell = GlobalKey();
                      return InkWell(
                        key: _inkwell,
                        onTap: () {
                          final RenderBox renderbox = _inkwell.currentContext!
                              .findRenderObject() as RenderBox;
                          final position = renderbox.localToGlobal(Offset.zero);
                          showMenu(
                            color: Colors.white,
                            elevation: 10,
                            shadowColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        username: userData["username"],
                                        email: userData["email"],
                                        about: userData["about"],
                                        imageurl: userData["userimageurl"],
                                        userid: userData["userid"],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              PopupMenuItem<String>(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.account_circle_outlined,
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
                                      builder: (context) => SearchUserProfile(
                                        username: userData["username"],
                                        email: userData["email"],
                                        about: userData["about"],
                                        imageurl: userData["userimageurl"],
                                        userid: userData["userid"],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );

                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => SearchUserProfile(
                          //       username: userData["username"],
                          //       email: userData["email"],
                          //       about: userData["about"],
                          //       imageurl: userData["userimageurl"],
                          //       userid: userData["userid"],
                          //     ),
                          //   ),
                          // );
                        },
                        child: CustomCard(
                          username: userData["username"],
                          imageurl: userData["userimageurl"],
                          color: Colors.white, trailing: Text(""),
                          // trailing: IconButton(
                          //     onPressed: () async {
                          //       await _firestore
                          //           .collection("Users")
                          //           .doc(currentUserId)
                          //           .collection("chats")
                          //           .doc(userData["userid"])
                          //           .set({"chat": true});
                          //
                          //       showCustomDialog(
                          //           "User",
                          //           "${userData["username"]} is added to your chat.",
                          //           context);
                          //     },
                          //     icon: Icon(Icons.add)),
                        ),
                      );
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
