import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:TriDot/HomeScreens/Profile/myprofile.dart';
import 'package:TriDot/HomeScreens/Profile/settings.dart';
import 'package:TriDot/HomeScreens/chathome.dart';
import 'package:TriDot/HomeScreens/followedchatlist.dart';
import 'package:TriDot/HomeScreens/searchuser.dart';
import 'package:TriDot/HomeScreens/updates.dart';
import 'package:TriDot/Logins/logreg.dart';

import '../Logins/showdialogs.dart';
import '../networkcheck.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

String currentUserId = "";

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool index = false;
  GlobalKey<ScaffoldState> drawerController = GlobalKey<ScaffoldState>();
  final _firestore = FirebaseFirestore.instance;
  final cUserid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentUserId = FirebaseAuth.instance.currentUser!.uid;
    });
    requestPermissions();
    onlineState();
    getUserEmailVerifiedOrNot();
    NetworkCheck().initializeInternetStatus(context);
    WidgetsBinding.instance.addObserver(this);
  }

  getUserEmailVerifiedOrNot() {
    bool verified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (verified == true) {
    } else if (verified == false) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LogReg(),
        ),
        (Route<dynamic> route) => false, // This removes all previous routes
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      FirebaseFirestore.instance.collection("Users").doc(currentUserId).update({"online": false});
    } else if (state == AppLifecycleState.resumed) {
      onlineState();
    }
  }

  @override
  void dispose() {
    super.dispose();
    NetworkCheck().cancelSubscription();
    WidgetsBinding.instance.removeObserver(this);
  }

  onlineState() {
    FirebaseFirestore.instance.collection("Users").doc(currentUserId).update({"online": true});
  }

  requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();

    if (await Permission.camera.isDenied || await Permission.storage.isDenied) {
      await Permission.camera.isGranted;
      await Permission.storage.isGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        key: drawerController,
        drawer: Drawer(
          width: MediaQuery.of(context).size.width - 130,
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
                    stream: _firestore.collection("Users").doc(cUserid).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                            top: 10,
                            left: 10,
                            child: CircleAvatar(
                              radius: 60,
                              child: ClipOval(
                                child: Image.network(
                                  errorBuilder: (context, error, stackTrace) {
                                    return CircularProgressIndicator();
                                  },
                                  width: 120,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                  imageurl,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 10,
                            child: Text(
                              username,
                              style: TextStyle(color: Colors.white, fontSize: 22),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Text(
                              email,
                              style: TextStyle(color: Colors.white, fontSize: 12),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(),
                    ),
                  );
                },
                leading: Icon(
                  color: Colors.black,
                  Icons.settings_outlined,
                  size: 30,
                ),
                title: Text(
                  "Settings",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {
                  showMessageBox("Logout", "Are You Sure To Logout?", context, "Yes", () {
                    if (mounted) {
                      FirebaseAuth.instance.signOut();
                      FirebaseFirestore.instance.collection("Users").doc(currentUserId).update({"online": false});
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogReg(),
                          ),
                          (Route<dynamic> route) => false);
                    }
                  });
                },
                leading: Icon(
                  color: Colors.red,
                  Icons.logout_outlined,
                  size: 30,
                ),
                title: Text(
                  "Log Out",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(
            index ? "Chats" : "Updates",
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: "Search Users",
              splashColor: Colors.white60,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchUser(),
                    ));
              },
              icon: Icon(
                Icons.search_rounded,
                color: Colors.black,
              ),
            ),
            IconButton(
                onPressed: () {
                  showMenu(
                    color: Colors.white,
                    elevation: 10,
                    shadowColor: Colors.black54,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    context: context,
                    position: const RelativeRect.fromLTRB(100.0, 20.0, 20.0, 0.0),
                    // Adjust position as needed
                    items: [
                      PopupMenuItem<String>(
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          showMessageBox("Logout", "Are You Sure To Logout?", context, "Yes", () {
                            if (mounted) {
                              FirebaseAuth.instance.signOut();
                              FirebaseFirestore.instance
                                  .collection("Users")
                                  .doc(currentUserId)
                                  .update({"online": false});
                              Navigator.pop(context);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LogReg(),
                                ),
                                (Route<dynamic> route) => false, // This removes all previous routes
                              );
                            }
                          });
                        },
                      ),
                      PopupMenuItem<String>(
                        child: Text('Settings'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(),
                              ));
                        },
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
        body: TabBarView(children: [const ChatHome(), Updates()]),
        floatingActionButton: FloatingActionButton(
          elevation: 10,
          splashColor: Colors.white60,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          autofocus: true,
          backgroundColor: Colors.blue.shade400,
          onPressed: () {
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
    );
  }
}
