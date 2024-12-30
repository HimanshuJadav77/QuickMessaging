import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.username,
    required this.imageurl,
    this.about,
    required this.color,
    required this.trailing,
    required this.subtitle,
  });

  // ignore: prefer_typing_uninitialized_variables
  final username;

  // ignore: prefer_typing_uninitialized_variables
  final imageurl;

  // ignore: prefer_typing_uninitialized_variables
  final about;
  final Color color;
  final Widget trailing;
  final Text subtitle;

  // ignore: prefer_typing_uninitialized_variables

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(),
      color: color,
      child: Padding(
        padding: subtitle.data!.isEmpty
            ? const EdgeInsets.only(top: 8.0,bottom: 8.0)
            : EdgeInsets.zero,
        child: ListTile(
          trailing: trailing,
          title: Text(
            username,
            style: TextStyle(fontSize: 18),
          ),
          subtitle: subtitle.data!.isNotEmpty ? subtitle : null,
          leading: InkWell(
              child: CircleAvatar(
                  radius: 30,
                  child: ClipOval(
                    child: Image.network(
                      width: 56,
                      fit: BoxFit.cover,
                      imageurl,
                      filterQuality: FilterQuality.high,
                    ),
                  ))),
        ),
      ),
    );
  }
}
