import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickmsg/Logins/register.dart';
import 'package:quickmsg/Ui/elvb.dart';

import 'login.dart';

class LogReg extends StatefulWidget {
  const LogReg({super.key});

  @override
  State<LogReg> createState() => _LogRegState();
}

class _LogRegState extends State<LogReg> {
  @override
  Widget build(BuildContext context) {
    logregcontainer(child, bool lr) {
      return showBottomSheet(
        sheetAnimationStyle:
            AnimationStyle(duration: const Duration(milliseconds: 700)),
        enableDrag: true,
        showDragHandle: true,
        elevation: 20,
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            physics: const ScrollPhysics(parent: RangeMaintainingScrollPhysics()),
            child: SizedBox(
              height: double.maxFinite,
              width: double.maxFinite,
              child: Center(
                child: child,
              ),
            ),
          );
        },
      );
    }

    Widget? child;
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(tileMode: TileMode.decal, colors: [
              Colors.deepPurple,
              Colors.indigo,
              Colors.blue,
            ]),
            color: Colors.blue),
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FaIcon(
                    FontAwesomeIcons.leaf,
                    size: 30,
                  ),
                ),
                Text(
                  "QuickMessaging",
                  style: TextStyle(fontSize: 30),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                textAlign: TextAlign.center,
                "QuickMessaging for Communicate with your friend and send updates to friends.",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            SizedBox(
              height: 500,
              child: Stack(
                children: [
                  Positioned(
                    top: 340,
                    left: 0,
                    right: 0,
                    bottom: 90,
                    child: Elvb(
                      backgroundcolor: Colors.blue.shade700,
                      foregroundcolor: Colors.white,
                      onpressed: () {
                        setState(() {
                          child = const Register();
                          logregcontainer(child, true);
                        });
                      },
                      name: "Register",
                    ),
                  ),
                  Positioned(
                    top: 410,
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Elvb(
                      onpressed: () {
                        setState(() {
                          child = const Login();
                          logregcontainer(child, false);
                        });
                      },
                      name: "Login",
                      foregroundcolor: Colors.blue,
                      backgroundcolor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
