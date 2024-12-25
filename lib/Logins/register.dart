import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickmsg/Logins/login.dart';
import 'package:quickmsg/Logins/showdialogs.dart';
import 'package:quickmsg/Logins/verification.dart';
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
  bool pass = true;
  bool cpass = true;
  bool registered = false;
  File? pickedImage;

  showImagePicker() {
    return showDialog(
      barrierColor: Colors.black45,
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            AlertDialog(
              elevation: 20,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                "Select Image",
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () async {
                      try {
                        final photo = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        if (photo != null) {
                          final tempImage = File(photo.path);
                          setState(() {
                            pickedImage = tempImage;
                          });
                        }
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        showSnackBar(context, "$e");
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    leading: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                    ),
                    title: const Text(
                      "Camera",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      try {
                        final photo = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (photo != null) {
                          final tempImage = File(photo.path);
                          setState(() {
                            pickedImage = tempImage;
                          });
                        }
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        showSnackBar(context, "$e");
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    leading: const Icon(Icons.photo_library_outlined,
                        color: Colors.black),
                    title: const Text("Gallery",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
            Positioned(
                top: 1,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.black,
                      )),
                )),
          ],
        );
      },
    );
  }

  register() async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim());
      if (mounted) Navigator.pop(context);
      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => Verification(
                pickedImage: pickedImage,
                user: usernameController.text.trim(),
                password: passController.text.trim(),
                email: emailController.text.trim()),
          ));
    } on FirebaseAuthException catch (e) {
      setState(() {
        registered = false;
      });
      // ignore: use_build_context_synchronously
      showSnackBar(context, "Error is $e");
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where("username", isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log("Error checking username: $e");
      return false;
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
          InkWell(
            onTap: showImagePicker,
            child: pickedImage != null
                ? CircleAvatar(
                    radius: 60,
                    child: ClipOval(
                      child: Image.file(
                        width: 120,
                        fit: BoxFit.cover,
                        pickedImage!,
                        filterQuality: FilterQuality.high,
                      ),
                    ))
                : const CircleAvatar(
                    backgroundColor: Colors.black12,
                    radius: 60,
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                      size: 60,
                    ),
                  ),
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
          const SizedBox(
            height: 20,
          ),
          registered
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
                  onpressed: () async {
                    if (usernameController.text != "" &&
                        emailController.text != "" &&
                        passController.text != "" &&
                        confirmPassController.text != "") {
                      if (passController.text != confirmPassController.text) {
                        showSnackBar(context, "Passwords Are Not Matched.");
                      } else if (passController.text.length < 6 &&
                          passController.text.length < 6) {
                        showSnackBar(context, "Password Length Must be 6.");
                      } else if (pickedImage == null) {
                        showSnackBar(context, "Please Select Image.");
                      } else {
                        setState(() {
                          registered = true;
                        });
                        bool isUserExist =
                            await checkUsernameExists(usernameController.text);

                        isUserExist
                            ? showCustomDialog("Register",
                                "Username Is Already Exist.", context)
                            : register();

                        Timer(
                          const Duration(seconds: 2),
                          () {
                            setState(() {
                              registered = false;
                            });
                          },
                        );
                      }
                    } else {
                      showSnackBar(context, "Please Fill All Fields.");
                    }
                  },
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
                "I have Already Account?",
                style: TextStyle(fontSize: 17),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    logregcontainer(const Login(), context);
                  },
                  child: const Text("Login",
                      style: TextStyle(fontSize: 18, color: Colors.blue)))
            ],
          )
        ],
      ),
    );
  }
}
