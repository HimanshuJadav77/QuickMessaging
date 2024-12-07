import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickmsg/Ui/elvb.dart';
import 'package:quickmsg/Ui/snackbar.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool disable = false;
  bool pass = false;
  bool cpass = false;

  register(String email, String password) {
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        auth.createUserWithEmailAndPassword(email: email, password: password);
        showSnackBar(context, "Check Email For Verification");
        Timer(const Duration(seconds: 2), () {
          auth.currentUser!.sendEmailVerification();
        });
        Timer(const Duration(seconds: 10), () {
          if (auth.currentUser!.emailVerified) {
            showSnackBar(context, "Register Successfully");
          } else {
            showSnackBar(context, "Verify Your Email First...");
          }
        });
      } else {
        showSnackBar(context, "Please Enter All Fields.");
      }
    } catch (e) {
      showSnackBar(context, "Error is $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Register",
                style: TextStyle(
                    fontSize: 35,
                    fontFamily: "karsyu",
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 70,
          ),
          const CircleAvatar(
            //child: Image.asset("assets/images/login.png"),
            radius: 60,
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: usernameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  label: const Text("Enter Username"),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.account_circle_outlined),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  label: const Text("Enter Email"),
                  prefixIcon: const Icon(Icons.mail_outline),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: passController,
              obscureText: pass,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  label: const Text("Enter Password"),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          pass = !pass;
                        });
                      },
                      icon: Icon(!pass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined)),
                  prefixIcon: const Icon(Icons.password_outlined),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              obscureText: cpass,
              controller: confirmPassController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  label: const Text("Enter Confirm Password"),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          cpass = !cpass;
                        });
                      },
                      icon: Icon(!cpass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined)),
                  prefixIcon: const Icon(Icons.password_sharp),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
            ),
          ),
          Elvb(
              onpressed: () {},
              name: "Register",
              foregroundcolor: Colors.white,
              backgroundcolor: Colors.blue),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "You have Already Account?",
                style: TextStyle(fontSize: 17),
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Login",
                      style: TextStyle(fontSize: 20, color: Colors.blue)))
            ],
          )
        ],
      ),
    );
  }
}
