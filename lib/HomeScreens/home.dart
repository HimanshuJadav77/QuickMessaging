import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickmsg/HomeScreens/chathome.dart';
import 'package:quickmsg/Logins/logreg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool index = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
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
              onPressed: () {},
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
            label: const Text("Search"),
            icon: const Icon(Icons.search),
            splashColor: Colors.white,
            backgroundColor: Colors.blue.shade300,
            focusColor: Colors.blue.shade200,
            onPressed: () {}),
      ),
    );
  }
}
