import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Ui/elvb.dart';
import '../Ui/snackbar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool pass = false;
  bool cpass = false;

  login(String email, String password) {
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        auth.signInWithEmailAndPassword(email: email, password: password);
        if (auth.currentUser!.emailVerified) {
          showSnackBar(context, "Login Successfully");
        } else {
          showSnackBar(context, "Verify Your Email First...");
        }
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
                "Login",
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
            height: 20,
          ),
          SizedBox(
            height: 300,
            width: 300,
            child: Image.asset("assets/images/login.png"),
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
          Elvb(
              onpressed: () {},
              name: "Login",
              foregroundcolor: Colors.white,
              backgroundcolor: Colors.blue),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "I have no any Account?",
                style: TextStyle(fontSize: 17),
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Register",
                      style: TextStyle(fontSize: 20, color: Colors.blue)))
            ],
          )
        ],
      ),
    );
  }
}
