import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickmsg/Ui/elvb.dart';



showVerification(String content, BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
      return AlertDialog(
        title: const Text(
          "Verification",
          style: TextStyle(color: Colors.blue, fontSize: 20),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Text(content),
        elevation: 10,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.currentUser!.delete();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.blue),
                  )),
              Elvb(
                  textsize: 15.0,
                  heigth: 30.0,
                  onpressed: () {
                    FirebaseAuth.instance.currentUser!.sendEmailVerification();
                  },
                  name: "Resend",
                  foregroundcolor: Colors.white,
                  backgroundcolor: Colors.blue)
            ],
          )
        ],
      );
    },
  );
}
