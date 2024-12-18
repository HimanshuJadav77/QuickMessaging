import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickmsg/HomeScreens/Profile/myprofile.dart';
import 'package:quickmsg/HomeScreens/chathome.dart';
import 'package:quickmsg/Logins/logreg.dart';

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
  String cUserImage = "";
  String cUserName = "";
  String cUserEmail = "";
  String cAbout = "";

  @override
  void initState() {
    super.initState();
    getCUserData();
  }

  getCUserData() async {
    final cUserData = await _firestore.collection("Users").doc(cUserid).get();
    setState(() {
      cUserImage = cUserData["userimageurl"];
      cUserName = cUserData["username"];
      cUserEmail = cUserData["email"];
      cAbout = cUserData["about"];
    });
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
                child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      left: 10,
                      child: CircleAvatar(
                        radius: 50,
                        child: ClipOval(
                          child: Image.network(
                            errorBuilder: (context, error, stackTrace) {
                              return CircularProgressIndicator();
                            },
                            width: 120,
                            fit: BoxFit.cover,
                            cUserImage,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      left: 120,
                      child: Text(
                        cUserName,
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ),
                    Positioned(
                      top: 110,
                      right: 48,
                      child: Text(
                        cUserEmail,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  ],
                ),
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
              // ListTile(
              //   onTap: () {},
              //   leading: Icon(
              //     Icons.logout,
              //     size: 30,
              //     color: Colors.red,
              //   ),
              //   title: Text(
              //     "Log out",
              //     style: TextStyle(color: Colors.red),
              //   ),
              // )
              Container(
                  color: Colors.transparent,
                  width: double.maxFinite,
                  height: 466,
                  child: Stack(
                    children: [
                      Positioned(
                          right: 10,
                          bottom: 10,
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
                            onPressed: () {},
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
                    context: context,
                    position: const RelativeRect.fromLTRB(
                        20.0, 20.0, 0.0, 0.0), // Adjust position as needed
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
        floatingActionButton: FloatingActionButton.extended(
            label: const Text(
              "Search",
              style: TextStyle(color: Colors.white),
            ),
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            splashColor: Colors.white,
            backgroundColor: Colors.blue.shade300,
            focusColor: Colors.blue.shade200,
            onPressed: () {}),
      ),
    );
  }
}
