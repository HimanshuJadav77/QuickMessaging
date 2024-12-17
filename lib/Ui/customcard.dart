import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard(
      {super.key,
      required this.username,
      required this.imageurl,
      required this.userid});

  // ignore: prefer_typing_uninitialized_variables
  final username;
  // ignore: prefer_typing_uninitialized_variables
  final imageurl;
  // ignore: prefer_typing_uninitialized_variables
  final userid;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!.uid;
    return Card(
      color: Colors.white,
      child: ListTile(
        trailing: const Text(""),
        title: Text(userid == user ? username + "(you)" : username),
        subtitle: const Text("Hello World...."),
        leading: InkWell(
            child: CircleAvatar(
                radius: 30,
                child: ClipOval(
                  child: Image.network(
                    width: 120,
                    fit: BoxFit.cover,
                    imageurl,
                    filterQuality: FilterQuality.high,
                  ),
                ))),
      ),
    );
  }
}
