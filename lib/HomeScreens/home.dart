import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickmsg/HomeScreens/Profile/myprofile.dart';
import 'package:quickmsg/HomeScreens/chathome.dart';
import 'package:quickmsg/HomeScreens/followedchatlist.dart';
import 'package:quickmsg/HomeScreens/searchuser.dart';
import 'package:quickmsg/Logins/logreg.dart';
import 'package:quickmsg/Ui/elvb.dart';
import 'package:quickmsg/socketService/socketservice.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool index = false;
  GlobalKey<ScaffoldState> drawerController = GlobalKey<ScaffoldState>();
  final _firestore = FirebaseFirestore.instance;
  final cUserid = FirebaseAuth.instance.currentUser!.uid;
  bool showMultibutton = false;

  @override
  void initState() {
    super.initState();
    SocketService().connect();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
          key: drawerController,
          drawer: Drawer(
            width: 300,
            child: Column(
              children: [
                Container(
                  width: double.maxFinite,
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.indigo.shade900,
                      Colors.indigo.shade700,
                      Colors.blue.shade600,
                      Colors.blueAccent.shade400,
                    ]),
                  ),
                  child: StreamBuilder(
                      stream: _firestore
                          .collection("Users")
                          .doc(cUserid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final data = snapshot.data!;
                        final imageurl = data["userimageurl"];
                        final username = data["username"];
                        final email = data["email"];

                        return Stack(
                          children: [
                            Positioned(
                              top: 50,
                              left: 5,
                              child: CircleAvatar(
                                radius: 50,
                                child: ClipOval(
                                  child: Image.network(
                                    errorBuilder: (context, error, stackTrace) {
                                      return CircularProgressIndicator();
                                    },
                                    width: 120,
                                    fit: BoxFit.cover,
                                    imageurl,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 80,
                              left: 110,
                              child: Text(
                                username,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 22),
                              ),
                            ),
                            Positioned(
                              top: 110,
                              left: 110,
                              child: Text(
                                email,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            )
                          ],
                        );
                      }),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyProfile(),
                        ));
                  },
                  leading: Icon(
                    Icons.account_circle_outlined,
                    size: 30,
                    color: Colors.black,
                  ),
                  title: Text(
                    "My Profile",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(
                    color: Colors.black,
                    Icons.settings_outlined,
                    size: 30,
                  ),
                  title: Text(
                    "settings",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(
                    color: Colors.black,
                    Icons.privacy_tip_outlined,
                    size: 30,
                  ),
                  title: Text(
                    "Privacy",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(
                    color: Colors.black,
                    Icons.info_outline_rounded,
                    size: 30,
                  ),
                  title: Text(
                    "About",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(
                    width: double.maxFinite,
                    height: 472,
                    child: Stack(
                      children: [
                        Positioned(
                            right: 10,
                            bottom: 0,
                            child: IconButton(
                              icon: Row(
                                children: [
                                  Icon(
                                    Icons.logout_outlined,
                                    size: 30,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "Log Out",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              color: Colors.red,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Logout",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      content: Text(
                                        "Are You Sure To Logout?",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                      elevation: 10,
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 14),
                                                )),
                                            Elvb(
                                                onpressed: () {
                                                  FirebaseAuth.instance
                                                      .signOut();
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LogReg(),
                                                    ),
                                                    (Route<dynamic> route) =>
                                                        false, // This removes all previous routes
                                                  );
                                                },
                                                name: "Yes",
                                                foregroundcolor: Colors.white,
                                                backgroundcolor: Colors.blue)
                                          ],
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                            )),
                      ],
                    )),
              ],
            ),
          ),
          appBar: AppBar(
            title: Text(
              index ? "Chats" : "Status",
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
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
                      position:
                          const RelativeRect.fromLTRB(100.0, 20.0, 20.0, 0.0),
                      // Adjust position as needed
                      items: [
                        PopupMenuItem<String>(
                          value: 'Option 1',
                          child: const Text('Logout'),
                          onTap: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LogReg(),
                                ));
                          },
                        ),
                        const PopupMenuItem<String>(
                          value: 'Option 2',
                          child: Text('Camera'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Option 3',
                          child: Text('Settings'),
                        ),
                      ],
                    );
                  },
                  icon: const Icon(Icons.more_vert_outlined))
            ],
            leading: IconButton(
                onPressed: () {
                  setState(() {
                    drawerController.currentState?.openDrawer();
                  });
                },
                icon: const Icon(
                  Icons.menu_outlined,
                  size: 30,
                )),
            bottom: TabBar(
                onTap: (value) {
                  setState(() {
                    if (value == 0) {
                      index = true;
                    } else if (value == 1) {
                      index = false;
                    }
                  });
                },
                automaticIndicatorColorAdjustment: true,
                unselectedLabelColor: Colors.black,
                labelColor: Colors.indigoAccent,
                tabs: const [
                  Tab(icon: FaIcon(FontAwesomeIcons.message)),
                  Tab(
                      icon: Icon(
                    Icons.update,
                    size: 30,
                  )),
                ]),
          ),
          body: TabBarView(children: [
            const ChatHome(),
            Container(
              height: 10,
              color: Colors.blue,
            )
          ]),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 200),
                height: showMultibutton ? 200 : 60,
                width: showMultibutton ? 70 : 60,
                child: showMultibutton
                    ? Stack(
                        children: [
                          Positioned(
                            right: 5,
                            bottom: 60,
                            child: FloatingActionButton(
                              elevation: 10,
                              splashColor: Colors.white60,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              autofocus: true,
                              backgroundColor: Colors.blue.shade400,
                              onPressed: () {
                                setState(() {
                                  showMultibutton = false;
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchUser(),
                                    ));
                              },
                              child: Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 10,
                            child: FloatingActionButton(
                              elevation: 10,
                              splashColor: Colors.white60,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              autofocus: true,
                              backgroundColor: Colors.blue.shade400,
                              onPressed: () {
                                setState(() {
                                  showMultibutton = false;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FollowedChatList(),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.chat_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 8,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showMultibutton = false;
                                  });
                                },
                                icon: Icon(Icons.close)),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: FloatingActionButton(
                          elevation: 10,
                          splashColor: Colors.white60,
                          backgroundColor: Colors.blue.shade400,
                          onPressed: () {
                            setState(() {
                              showMultibutton = true;
                            });
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
              )
            ],
          )),
    );
  }
}
