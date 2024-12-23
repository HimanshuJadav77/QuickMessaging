import 'package:flutter/material.dart';

logregcontainer(child, BuildContext context) {
  return showBottomSheet(
    sheetAnimationStyle:
        AnimationStyle(duration: const Duration(milliseconds: 700)),
    enableDrag: true,
    showDragHandle: true,
    elevation: 20,
    backgroundColor: Colors.white,
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        physics: const ScrollPhysics(parent: RangeMaintainingScrollPhysics()),
        child: SizedBox(
          height: double.maxFinite,
          width: double.maxFinite,
          child: Center(
            child: child,
          ),
        ),
      );
    },
  );
}

showCustomDialog(String title, String content, BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(
              color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Text(
          content,
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        elevation: 10,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Ok",
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  )),
            ],
          )
        ],
      );
    },
  );
}
