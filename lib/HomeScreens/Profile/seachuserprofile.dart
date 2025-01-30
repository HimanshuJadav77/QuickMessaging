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
  bool private = true;
  bool public = true;
  final _firestore = FirebaseFirestore.instance;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool followState = false;
  var follower = 0;
  var following = 0;
  bool block = false;
  bool blockedbyUser = false;
  bool requested = false;
  var privacyM;

  @override
  void initState() {
    super.initState();
  }

  blockUser(blockUserid) async {
    if (block) {
      await FirebaseFirestore.instance
          .collection("block")
          .doc(currentUserId)
          .collection("blockedid")
          .doc(blockUserid)
          .set({"blocked": false});
      setState(() {
        block = false;
      });
    } else {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUserId)
          .collection("followers")
          .doc(widget.userid)
          .update({"follower": false});
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUserId)
          .collection("following")
          .doc(widget.userid)
          .update({"following": false});
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userid)
          .collection("followers")
          .doc(currentUserId)
          .update({"follower": false});
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userid)
          .collection("following")
          .doc(currentUserId)
          .update({"following": false});
      await FirebaseFirestore.instance
          .collection("block")
          .doc(currentUserId)
          .collection("blockedid")
          .doc(blockUserid)
          .set({"blocked": true});
      setState(() {
        block = true;
      });
    }
  }

  getBlockState() async {
    final getBlockState = await FirebaseFirestore.instance
        .collection("block")
        .doc(currentUserId)
        .collection("blockedid")
        .doc(widget.userid)
        .get();
    final data = getBlockState.data()?["blocked"].toString();
    if (data == "true") {
      setState(() {
        block = true;
      });
    }
  }

  request() {
    if (requested) {
      _firestore
          .collection("Users")
          .doc(currentUserId)
          .collection("requests")
          .doc(widget.userid)
          .set({"requested": true});

      _firestore
          .collection("Users")
          .doc(widget.userid)
          .collection("requests")
          .doc(currentUserId)
          .set({"request": true});
    } else if (!requested) {
      _firestore
          .collection("Users")
          .doc(currentUserId)
          .collection("requests")
          .doc(widget.userid)
          .set({"requested": false});

      _firestore
          .collection("Users")
          .doc(widget.userid)
          .collection("requests")
          .doc(currentUserId)
          .set({"request": false});
    }
  }

  Future<void> followUnfollowUser(bool state) async {
    final getBlockState =
        await _firestore.collection("block").doc(currentUserId).collection("blockedid").doc(widget.userid).get();
    if (getBlockState.exists) {
      var block = getBlockState["blocked"];
      if (block.toString() == "true") {
        mounted ? showSnackBar(context, "Unblock ${widget.username} first.") : null;
      } else if (block.toString() == "false") {
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
            setState(() {
              requested = false;
            });
          }
        } on FirebaseException catch (e) {
          mounted ? showSnackBar(context, "$e") : null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          blockedbyUser
              ? Center()
              : IconButton(
                  onPressed: () {
                    showMenu(
                      color: Colors.white,
                      elevation: 10,
                      shadowColor: Colors.black54,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      context: context,
                      position: RelativeRect.fromLTRB(100, 20, 27, 20),
                      // Adjust position as needed
                      items: [
                        PopupMenuItem<String>(
                          value: '',
                          child: Text(
                            block ? "Unblock" : 'Block',
                            style: TextStyle(color: block ? Colors.blue : Colors.red),
                          ),
                          onTap: () {
                            showMessageBox(
                                block ? "Unblock" : "Block",
                                block
                                    ? "Are you sure to Unblock ${widget.username}?"
                                    : "Are you sure to  block ${widget.username}?",
                                context,
                                block ? "Unblock" : "Block", () {
                              blockUser(widget.userid);
                              Navigator.pop(context);
                            });
                          },
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
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("block")
              .doc(widget.userid)
              .collection("blockedid")
              .doc(currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {}
            if (!snapshot.hasData || !snapshot.data!.exists) {
              FirebaseFirestore.instance
                  .collection("block")
                  .doc(widget.userid)
                  .collection("blockedid")
                  .doc(currentUserId)
                  .set({"blocked": false});
            }
            if (snapshot.hasData) {
              final blockState = snapshot.data!["blocked"];
              if (blockState == true) {
                blockedbyUser = true;
              } else if (blockState == false) {
                blockedbyUser = false;
              }
            }

            return blockedbyUser
                ? Center(
                    child: Text("${widget.username} has been blocked you."),
                  )
                : ListView(
                    children: [
                      SizedBox(
                        height: 190,
                        child: Stack(
                          children: [
                            StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("Users")
                                    .doc(widget.userid) // Assuming currentUserId is defined somewhere
                                    .collection("privacy")
                                    .doc("mode")
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return SizedBox();
                                  }
                                  if (!snapshot.hasData || !snapshot.data!.exists) {
                                    FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(widget.userid)
                                        .collection("privacy")
                                        .doc("mode")
                                        .set({"privacy": "public"});
                                  }
                                  if (snapshot.hasData) {
                                    final privacy = snapshot.data?["privacy"];

                                    if (privacy == "private") {
                                      private = true;
                                      public = false;
                                    } else if (privacy == "public") {
                                      private = false;
                                      public = true;
                                    }

                                    return Positioned(
                                        top: 100,
                                        right: 100,
                                        child: Text(
                                          privacy == "private" ? "Private" : "Public",
                                          style: TextStyle(color: Colors.blue),
                                        ));
                                  }
                                  return SizedBox();
                                }),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 30.0),
                                  child: Card(
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
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
                                    if (private && followState || public) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FollowFollowingPage(
                                              userid: widget.userid,
                                            ),
                                          ));
                                    }
                                  },
                                  child: SizedBox(
                                    width: 270,
                                    height: 70,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 40, top: 5),
                                            child: Text(
                                              "Follower",
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 30,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 40, top: 5),
                                            child: Text(
                                              "Following",
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 195,
                                          top: 25,
                                          child: StreamBuilder(
                                              stream: _firestore
                                                  .collection("Users")
                                                  .doc(widget.userid)
                                                  .collection("followers")
                                                  .where("follower", isEqualTo: true)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return SizedBox();
                                                }
                                                if (!snapshot.hasData && snapshot.data!.docs.isEmpty) {
                                                  _firestore
                                                      .collection("Users")
                                                      .doc(widget.userid)
                                                      .collection("followers")
                                                      .doc(currentUserId)
                                                      .set({"follower": false});
                                                  return Center();
                                                }
                                                return Padding(
                                                  padding: const EdgeInsets.only(left: 70, top: 5),
                                                  child: Text(
                                                    "${snapshot.data?.docs.length}",
                                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                                                  ),
                                                );
                                              }),
                                        ),
                                        Positioned(
                                          right: 65,
                                          top: 25,
                                          child: StreamBuilder(
                                              stream: _firestore
                                                  .collection("Users")
                                                  .doc(widget.userid)
                                                  .collection("following")
                                                  .where("following", isEqualTo: true)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return SizedBox();
                                                }
                                                if (!snapshot.hasData && snapshot.data!.docs.isEmpty) {
                                                  _firestore
                                                      .collection("Users")
                                                      .doc(widget.userid)
                                                      .collection("following")
                                                      .doc(currentUserId)
                                                      .set({"following": false});
                                                  return Center();
                                                }
                                                return Padding(
                                                  padding: const EdgeInsets.only(left: 70, top: 5),
                                                  child: Text(
                                                    "${snapshot.data!.docs.length}",
                                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
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
                                      width: MediaQuery.of(context).size.width - 95,
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
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                        onPressed: () async {
                                          if (private && followState || public) {
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
                                                .set({"chat": true, "time": FieldValue.serverTimestamp()});
                                          } else {
                                            showSnackBar(context, "This profile is private follow first.");
                                          }
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
                                    style: TextStyle(fontSize: 15, color: Colors.blue, fontWeight: FontWeight.bold),
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
                              style: TextStyle(fontSize: 15, color: Colors.blue, fontWeight: FontWeight.bold),
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
                                title: Text(
                                  "About",
                                  style: TextStyle(fontSize: 15, color: Colors.blue, fontWeight: FontWeight.bold),
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
                        child: StreamBuilder(
                            stream: _firestore
                                .collection("Users")
                                .doc(currentUserId)
                                .collection("following")
                                .doc(widget.userid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                _firestore
                                    .collection("Users")
                                    .doc(currentUserId)
                                    .collection("following")
                                    .doc(widget.userid)
                                    .set({"following": false});
                              }

                              if (snapshot.hasError) {
                                return Center();
                              }

                              if (snapshot.hasData) {
                                final following = snapshot.data!["following"];

                                if (following) {
                                  followState = true;
                                } else {
                                  followState = false;
                                }

                                return public && !following || following && public || private && following
                                    ? Padding(
                                        padding: EdgeInsets.only(left: 5, right: 5),
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue.shade400,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                                          onPressed: () {
                                            !block
                                                ? setState(() {
                                                    // followState = !followState;
                                                    if (!following) {
                                                      followUnfollowUser(true);
                                                    } else if (following) {
                                                      followUnfollowUser(false);
                                                      requested = false;
                                                      request();
                                                    }
                                                  })
                                                : showSnackBar(context, "Unblock ${widget.username} first.");
                                          },
                                          icon: Icon(
                                            following ? Icons.check_circle_outline : Icons.person_add_alt,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            following ? "Following" : "Follow",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : private && !following && !public
                                        ? Padding(
                                            padding: EdgeInsets.only(left: 5, right: 5),
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue.shade400,
                                                  shape:
                                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                                              onPressed: () {
                                                !block
                                                    ? setState(() {
                                                        requested = !requested;
                                                        request();
                                                      })
                                                    : showSnackBar(context, "Unblock ${widget.username} first.");
                                              },
                                              icon: Icon(
                                                requested ? Icons.check_circle_outline : Icons.person_add_alt,
                                                color: Colors.white,
                                              ),
                                              label: Text(
                                                requested ? "Requested" : "Follow",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          )
                                        : SizedBox();
                              }
                              return SizedBox();
                            }),
                      )
                    ],
                  );
          }),
    );
  }
}
