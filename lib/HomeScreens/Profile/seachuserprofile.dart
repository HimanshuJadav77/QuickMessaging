// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:quickmsg/HomeScreens/Profile/followfollowing.dart';
import 'package:quickmsg/HomeScreens/chatscreen.dart';
import 'package:quickmsg/Logins/showdialogs.dart';
import 'package:quickmsg/Ui/snackbar.dart';

class SearchUserProfile extends StatefulWidget {
  const SearchUserProfile(
      {super.key,
      required this.username,
      required this.email,
      required this.about,
      required this.imageurl,
      required this.userid});

  final imageurl;
  final username;
  final email;
  final about;
  final userid;

  @override
  State<SearchUserProfile> createState() => _SearchUserProfileState();
}

class _SearchUserProfileState extends State<SearchUserProfile> {
  final _firestore = FirebaseFirestore.instance;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool followState = false;
  var follower = 0;
  var following = 0;

  @override
  void initState() {
    super.initState();

    isFollowing();
  }

  Future<void> isFollowing() async {
    try {
      final fetchIsFollowing = await _firestore
          .collection("Users")
          .doc(widget.userid)
          .collection("followers")
          .doc(currentUserId)
          .get();
      final field = fetchIsFollowing.data();
      if (field?["follower"] == true) {
        setState(() {
          followState = true;
        });
      }
    } on FirebaseException catch (e) {
      if (mounted) showCustomDialog("Following", "$e", context);
    }
  }

  Future<void> followUnfollowUser(bool state) async {
    try {
      if (state) {
        _firestore
            .collection("Users")
            .doc(currentUserId)
            .collection("following")
            .doc(widget.userid)
            .set({"following": true});

        _firestore
            .collection("Users")
            .doc(widget.userid)
            .collection("followers")
            .doc(currentUserId)
            .set({"follower": true});
        showSnackBar(context, "User Followed.");
      } else if (!state) {
        _firestore
            .collection("Users")
            .doc(currentUserId)
            .collection("following")
            .doc(widget.userid)
            .update({"following": false});
        _firestore
            .collection("Users")
            .doc(widget.userid)
            .collection("followers")
            .doc(currentUserId)
            .set({"follower": false});
        showSnackBar(context, "User Unfollowed.");
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showMenu(
                  color: Colors.white,
                  elevation: 10,
                  shadowColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  context: context,
                  position: RelativeRect.fromLTRB(100, 20, 27, 20),
                  // Adjust position as needed
                  items: [
                    PopupMenuItem<String>(
                      value: '',
                      child: const Text(
                        'Block',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {},
                    ),
                    const PopupMenuItem<String>(
                      value: 'Option 3',
                      child: Text('Settings'),
                    ),
                  ],
                );
              },
              icon: Icon(Icons.more_vert_outlined))
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new)),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60)),
                        child: CircleAvatar(
                          radius: 50,
                          child: ClipOval(
                            child: Image.network(
                              errorBuilder: (context, error, stackTrace) {
                                return CircularProgressIndicator();
                              },
                              width: 120,
                              fit: BoxFit.cover,
                              widget.imageurl,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FollowFollowingPage(
                                userid: widget.userid,
                              ),
                            ));
                      },
                      child: SizedBox(
                        width: 270,
                        height: 70,
                        child: Stack(
                          children: [
                            Positioned(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, top: 5),
                                child: Text(
                                  "Follower",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 30,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, top: 5),
                                child: Text(
                                  "Following",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 195,
                              top: 25,
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: _firestore
                                      .collection("Users")
                                      .doc(widget.userid)
                                      .collection("followers")
                                      .where("follower", isEqualTo: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Padding(
                                        padding:
                                            EdgeInsets.only(top: 10, left: 15),
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      );
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70, top: 5),
                                      child: Text(
                                        "${snapshot.data?.docs.length}",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    );
                                  }),
                            ),
                            Positioned(
                              right: 65,
                              top: 25,
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: _firestore
                                      .collection("Users")
                                      .doc(widget.userid)
                                      .collection("following")
                                      .where("following", isEqualTo: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Padding(
                                        padding:
                                            EdgeInsets.only(top: 10, left: 15),
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      );
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 70, top: 5),
                                      child: Text(
                                        "${snapshot.data!.docs.length}",
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 90,
                    left: 10,
                    right: 5,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 310,
                          child: Divider(
                            color: Colors.black54,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: SizedBox(
                          height: 70,
                          width: 70,
                          child: FloatingActionButton(
                            elevation: 10,
                            splashColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      imageurl: widget.imageurl,
                                      username: widget.username,
                                      userid: widget.userid,
                                      about: widget.about,
                                      email: widget.email,
                                    ),
                                  ));
                              await _firestore
                                  .collection("Users")
                                  .doc(currentUserId)
                                  .collection("chats")
                                  .doc(widget.userid)
                                  .set({
                                "chat": true,
                                "time": FieldValue.serverTimestamp()
                              });
                            },
                            backgroundColor: Colors.blue.shade400,
                            child: Icon(
                              Icons.message_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 2,
                  right: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        "Username",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        widget.username,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                title: Text(
                  "Email",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  widget.email,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ),
          widget.about != ""
              ? Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      "About",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      widget.about,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                )
              : Center(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Divider(
              color: Colors.black54,
            ),
          ),
          SizedBox(
            width: 400,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              onPressed: () {
                setState(() {
                  followState = !followState;
                  if (followState) {
                    followUnfollowUser(true);
                  } else if (!followState) {
                    followUnfollowUser(false);
                  }
                });
              },
              icon: Icon(
                followState ? Icons.check_circle_outline : Icons.person_add_alt,
                color: Colors.white,
              ),
              label: Text(
                followState ? "Following" : "Follow",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
