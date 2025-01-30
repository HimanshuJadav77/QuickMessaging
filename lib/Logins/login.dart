import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickmsg/HomeScreens/home.dart';
import 'package:quickmsg/Logins/register.dart';
import 'package:quickmsg/Logins/showdialogs.dart';
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
  bool loggedin = false;

  login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ));
      } else {
        showCustomDialog(
            "Login",
            "Your Email Is Not Verified We Have Been Sent Email Verification Link After Link Verification Login Again.",
            // ignore: use_build_context_synchronously
            context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        loggedin = false;
      });
      // ignore: use_build_context_synchronously
      showSnackBar(context, "$e");
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
                style: TextStyle(fontSize: 35, fontFamily: "karsyu", fontWeight: FontWeight.w400, color: Colors.black),
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
                      borderSide: const BorderSide(color: Colors.blue), borderRadius: BorderRadius.circular(30)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: passController,
              obscureText: !pass,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  label: const Text("Enter Password"),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          pass = !pass;
                        });
                      },
                      icon: Icon(pass ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
                  prefixIcon: const Icon(Icons.password_outlined),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue), borderRadius: BorderRadius.circular(30)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(left: 275.0),
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
          loggedin
              ? const Center(
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                )
              : Elvb(
                  textsize: 17.0,
                  heigth: 50.0,
                  onpressed: () {
                    if (emailController.text != "" && passController.text != "") {
                      login(emailController.text, passController.text);
                      setState(() {
                        loggedin = true;
                      });
                    } else {
                      showSnackBar(context, "Please Fill All TextBoxes.");
                    }
                  },
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
                  onPressed: () {
                    Navigator.pop(context);
                    logregcontainer(const Register(), context);
                  },
                  child: const Text("Register", style: TextStyle(fontSize: 18, color: Colors.blue)))
            ],
          )
        ],
      ),
    );
  }
}
