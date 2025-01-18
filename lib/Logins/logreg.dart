import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickmsg/Logins/register.dart';
import 'package:quickmsg/Logins/showdialogs.dart';
import 'package:quickmsg/Ui/elvb.dart';
import 'login.dart';

class LogReg extends StatefulWidget {
  const LogReg({super.key});

  @override
  State<LogReg> createState() => _LogRegState();
}

class _LogRegState extends State<LogReg> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
    await Permission.videos.request();
    await Permission.microphone.request();
    if (await Permission.camera.isDenied ||
        await Permission.storage.isDenied ||
        await Permission.videos.isDenied ||
        await Permission.microphone.isDenied) {
      await Permission.camera.isGranted;
      await Permission.storage.isGranted;
      await Permission.videos.isGranted;
      await Permission.microphone.isGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            gradient: LinearGradient(tileMode: TileMode.decal, colors: [
              Colors.deepPurple,
              Colors.indigo,
              Colors.blue,
            ]),
            color: Colors.blue),
        child: ListView(
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  "QuickMessaging",
                  style: TextStyle(fontSize: 30, color: Colors.white),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                textAlign: TextAlign.center,
                "QuickMessaging for Communicate with your friend and send updates to friends.",
                style: TextStyle(fontSize: 20, color: Colors.white),
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
                    child: Builder(builder: (context) {
                      return Elvb(
                        textsize: 17.0,
                        backgroundcolor: Colors.blue.shade700,
                        foregroundcolor: Colors.white,
                        onpressed: () {
                          logregcontainer(const Register(), context);
                        },
                        name: "Register",
                      );
                    }),
                  ),
                  Positioned(
                    top: 410,
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Builder(builder: (context) {
                      return Elvb(
                        textsize: 17.0,
                        onpressed: () {
                          logregcontainer(const Login(), context);
                        },
                        name: "Login",
                        foregroundcolor: Colors.blue,
                        backgroundcolor: Colors.white,
                      );
                    }),
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
