import 'package:flutter/material.dart';

class Sendcard extends StatelessWidget {
  const Sendcard({super.key, this.message});

  // ignore: prefer_typing_uninitialized_variables
  final message;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 50,
          ),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blue.shade700),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(0),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            color: Colors.blue.shade500,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 60, top: 5, bottom: 10),
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
                Positioned(
                    bottom: 2,
                    right: 15,
                    child: Text(
                      "10:00",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ))
              ],
            ),
          ),
        ));
  }
}
