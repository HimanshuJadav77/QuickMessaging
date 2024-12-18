// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Ui/snackbar.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({
    super.key,
  });

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  File? pickedImage;
  bool modifyUsername = false;
  bool modifyAbout = false;
  final aboutC = TextEditingController();
  final usernameC = TextEditingController();
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final userid = FirebaseAuth.instance.currentUser!.uid;
  bool loading = false;
  final userData = FirebaseFirestore.instance
      .collection("Users")
      .doc(FirebaseAuth.instance.currentUser!.uid);
  var username;
  var imageurl;
  var email;
  var about;

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

  Future<bool> checkUsernameExists(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection("Users")
          .where("username", isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error checking username: $e");
      return false;
    }
  }

  updateProfile() async {
    try {
      setState(() {
        loading = true;
      });
      if (pickedImage != null) {
        UploadTask uploadTask =
            _storage.ref("UsersImage").child(userid).putFile(pickedImage!);
        TaskSnapshot taskSnapshot = await uploadTask;
        final imageurl = await taskSnapshot.ref.getDownloadURL();
        await _firestore
            .collection("Users")
            .doc(userid)
            .update({"userimageurl": imageurl});
        showSnackBar(context, "Image Updated.");
      } else if (usernameC.text != username && modifyUsername) {
        bool isUsernameExist = await checkUsernameExists(usernameC.text);
        if (!isUsernameExist) {
          await _firestore
              .collection("Users")
              .doc(userid)
              .update({"username": usernameC.text});
          showSnackBar(context, "Username Updated.");
        } else {
          showSnackBar(context, "Username Already Exist.");
        }
      } else if (aboutC.text != about && modifyAbout) {
        await _firestore
            .collection("Users")
            .doc(userid)
            .update({"about": aboutC.text});
        showSnackBar(context, "About Updated.");
      }

      setState(() {
        loading = false;
        modifyAbout = false;
        modifyUsername = false;
        pickedImage = null;
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: userData.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data?.data() as Map<String, dynamic>;
            username = data["username"].toString();
            imageurl = data["userimageurl"].toString();
            email = data["email"].toString();
            about = data["about"].toString();

            return Scaffold(
              appBar: AppBar(
                actions: [
                  pickedImage != null ||
                          modifyAbout == true ||
                          modifyUsername == true
                      ? Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    pickedImage = null;
                                    modifyAbout = false;
                                    modifyUsername = false;
                                  });
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.red),
                                )),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: VerticalDivider(),
                            ),
                            !loading
                                ? TextButton(
                                    onPressed: () {
                                      updateProfile();
                                    },
                                    child: Text(
                                      "Update",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.blue),
                                    ))
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator()),
                                  ),
                          ],
                        )
                      : Text(""),
                ],
                title: Text(
                  "My Profile",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new)),
              ),
              body: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            child: ClipOval(
                              child: pickedImage != null
                                  ? Image.file(
                                      width: 120,
                                      fit: BoxFit.cover,
                                      pickedImage!,
                                      filterQuality: FilterQuality.high,
                                    )
                                  : Image.network(
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return CircularProgressIndicator();
                                      },
                                      width: 120,
                                      fit: BoxFit.cover,
                                      imageurl,
                                      filterQuality: FilterQuality.high,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 85,
                            right: 2,
                            child: CircleAvatar(
                              backgroundColor: Colors.white60,
                              child: IconButton(
                                  onPressed: () {
                                    showImagePicker();
                                  },
                                  icon: Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.black,
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () {},
                      leading: Icon(
                        color: Colors.blue,
                        Icons.person_2_outlined,
                        size: 30,
                      ),
                      title: Text(
                        "Username",
                        style: TextStyle(fontSize: 15, color: Colors.blue),
                      ),
                      subtitle: modifyUsername
                          ? TextFormField(
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                              autofocus: true,
                              controller: usernameC,
                            )
                          : Text(
                              username,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                      trailing: modifyUsername
                          ? null
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  modifyUsername = true;
                                  usernameC.text = username;
                                });
                              },
                              icon: Icon(
                                color: Colors.blue,
                                Icons.mode_edit_outline_outlined,
                                size: 30,
                              )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () {},
                      leading: Icon(
                        color: Colors.blue,
                        Icons.email_outlined,
                        size: 30,
                      ),
                      title: Text(
                        "Email",
                        style: TextStyle(fontSize: 15, color: Colors.blue),
                      ),
                      subtitle: Text(
                        email,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () {},
                      leading: Icon(
                        color: Colors.blue,
                        Icons.info_outline_rounded,
                        size: 30,
                      ),
                      title: Text(
                        "About",
                        style: TextStyle(fontSize: 15, color: Colors.blue),
                      ),
                      subtitle: modifyAbout
                          ? TextFormField(
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                              autofocus: true,
                              controller: aboutC,
                            )
                          : Text(
                              about,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                      trailing: modifyAbout
                          ? null
                          : IconButton(
                              onPressed: () {
                                setState(() {
                                  modifyAbout = true;
                                  aboutC.text = about;
                                });
                              },
                              icon: Icon(
                                color: Colors.blue,
                                Icons.mode_edit_outline_outlined,
                                size: 30,
                              )),
                    ),
                  )
                ],
              ),
            );
          }
          return Center();
        });
  }
}
