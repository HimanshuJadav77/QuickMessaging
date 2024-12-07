import 'package:flutter/material.dart';

class Elvb extends StatelessWidget {
  const Elvb(
      {super.key,
      required this.onpressed,
      required this.name,
      required this.foregroundcolor,
      required this.backgroundcolor});

  final VoidCallback onpressed;
  final String name;
  final Color foregroundcolor;
  final Color backgroundcolor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 50,
        width: double.maxFinite,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundcolor,
              foregroundColor: foregroundcolor,
              elevation: 20,
              shadowColor: Colors.blueAccent,
            ),
            onPressed: onpressed,
            child: Text(
              name,
              style: const TextStyle(fontSize: 18),
            )),
      ),
    );
  }
}
