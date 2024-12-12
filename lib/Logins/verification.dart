import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quickmsg/HomeScreens/home.dart';
import 'package:quickmsg/Logins/logreg.dart';
import 'package:quickmsg/Ui/elvb.dart';
import 'package:quickmsg/Ui/snackbar.dart';

class Verification extends StatefulWidget {
  const Verification(
      {super.key,
      required this.pickedImage,
      required this.user,
      required this.password,
      required this.email});

  final File? pickedImage;
  final String user;
  final String password;
  final String email;

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final _auth = FirebaseAuth.instance;
  bool Resend = false;
  Timer? timer;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

  @override
  void initState() {
    super.initState();
    sendEmailVerification();
    timer = Timer.periodic(
        const Duration(seconds: 2), (timer) => checkUserVerified());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  sendEmailVerification() {
    Timer(
      const Duration(seconds: 1),
      () {
        _auth.currentUser?.sendEmailVerification();
      },
    );
  }

  checkUserVerified() async {
    await _auth.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        UploadTask uploadTask = _storage
            .ref("UsersImage")
            .child(user!.uid)
            .putFile(widget.pickedImage!);
        TaskSnapshot taskSnapshot = await uploadTask;
        final imageurl = await taskSnapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
          "username": widget.user,
          "email": widget.email,
          "password": widget.password,
          "userimageurl": imageurl,
        });
        timer!.cancel();
      } on FirebaseException catch (e) {
        showSnackBar(context, "$e");
      }
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const HomeScreen()
      : Scaffold(
          appBar: AppBar(
            title: const Text(
              "Verification",
              style: TextStyle(fontSize: 25, color: Colors.blue),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                  "A Verification Link Send To Your Gmail Verify It.",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !Resend
                      ? Elvb(
                          textsize: 17.0,
                          heigth: 50.0,
                          width: 150.0,
                          onpressed: () {
                            _auth.currentUser!.sendEmailVerification();
                            setState(() {
                              Resend = true;
                            });
                            Timer(
                              const Duration(seconds: 5),
                              () {
                                setState(() {
                                  Resend = false;
                                });
                              },
                            );
                          },
                          name: "Resend",
                          foregroundcolor: Colors.white,
                          backgroundcolor: Colors.blue)
                      : const Center(
                          child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                          ),
                        )),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      fixedSize: const Size(150, 50),
                    ),
                    onPressed: () {
                      _auth.currentUser!.delete();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LogReg(),
                          ));
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blue, fontSize: 17),
                    ),
                  )
                ],
              )
            ],
          ),
        );
}
