import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quickmsg/Logins/logreg.dart';

import 'home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key, this.snapshot});

  // ignore: prefer_typing_uninitialized_variables
  final snapshot;

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  void checkUser() {
    Timer(
      const Duration(seconds: 3),
      () {
        if (widget.snapshot.hasData) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LogReg(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Quick Messaging"),
    );
  }
}
