import 'package:flutter/material.dart';

class Receivecard extends StatelessWidget {
  const Receivecard({super.key, this.message});

  // ignore: prefer_typing_uninitialized_variables
  final message;


  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 50,
          ),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            color: Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 60, top: 5, bottom: 10),
                  child: Text(message,style: TextStyle(fontSize: 17,color: Colors.black),),
                ),
                Positioned(bottom: 2, right: 15, child: Text("10:00",style: TextStyle(fontSize: 12),))
              ],
            ),
          ),
        ));
  }
}
