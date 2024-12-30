import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:quickmsg/HomeScreens/Profile/seachuserprofile.dart';
import 'package:quickmsg/Ui/receivecard.dart';
import 'package:quickmsg/Ui/sendcard.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen(
      {super.key,
      required this.imageurl,
      required this.username,
      required this.userid,
      required this.about,
      required this.email});

  // ignore: prefer_typing_uninitialized_variables
  final imageurl;

  // ignore: prefer_typing_uninitialized_variables
  final about;

  // ignore: prefer_typing_uninitialized_variables
  final email;

  // ignore: prefer_typing_uninitialized_variables
  final username;

  // ignore: prefer_typing_uninitialized_variables
  final userid;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final sendmsgC = TextEditingController();
  final firestore = FirebaseFirestore.instance.collection("Users");
  final userid = FirebaseAuth.instance.currentUser!.uid;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.linear,
        );
      }
    });
  }

  void sendMessage(String message, sender, receiver) async {
    if (sendmsgC.text.isNotEmpty) {
      // SocketService().sendMessage(message, sender, receiver);
      await firestore
          .doc(userid)
          .collection("save_chat")
          .doc(receiver)
          .collection("messages")
          .add({
        "sender": userid,
        "receiver": receiver,
        "message": message,
        "time": DateTime.now().toLocal()
      });
      await firestore
          .doc(receiver)
          .collection("save_chat")
          .doc(userid)
          .collection("messages")
          .add({
        "sender": userid,
        "receiver": receiver,
        "message": message,
        "time": DateTime.now().toLocal()
      });
      scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 300,
        elevation: 2,
        leading: SizedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios_new)),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchUserProfile(
                          username: widget.username,
                          email: widget.email,
                          about: widget.about,
                          imageurl: widget.imageurl,
                          userid: widget.userid),
                    ),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 25,
                        child: ClipOval(
                          child: Image.network(
                            width: 55,
                            fit: BoxFit.cover,
                            widget.imageurl,
                            filterQuality: FilterQuality.high,
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        widget.username,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.more_vert_outlined))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: firestore
                    .doc(userid)
                    .collection("save_chat")
                    .doc(widget.userid)
                    .collection("messages")
                    .orderBy("time")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text("No Messages"),
                    );
                  }
                  final messageList = snapshot.data!.docs.toList();
                  scrollToBottom();
                  return ListView.builder(
                    controller: _scrollController,
                    physics: ScrollPhysics(parent: PageScrollPhysics()),
                    shrinkWrap: true,
                    itemCount: messageList.length,
                    itemBuilder: (context, index) {
                      final messageData = messageList[index];
                      final txtMessage = messageData["message"];
                      final senderId = messageData["sender"];
                      final timestamp = messageData["time"];
                      final formatedTime =
                          DateFormat("hh:mm a").format(timestamp.toDate());

                      if (senderId == userid) {
                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Sendcard(
                            time: formatedTime,
                            message: txtMessage,
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Receivecard(
                            time: formatedTime,
                            message: txtMessage,
                          ),
                        );
                      }
                    },
                  );
                }),
          ),
          Container(
            height: 70,
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                      width: 330,
                      child: TextFormField(
                        controller: sendmsgC,
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                              onPressed: () {},
                              icon: FaIcon(FontAwesomeIcons.faceSmile)),
                          suffix: FaIcon(FontAwesomeIcons.paperclip),
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black26),
                              borderRadius: BorderRadius.circular(30)),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black26),
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      )),
                ),
                FloatingActionButton(
                  autofocus: true,
                  elevation: 10,
                  backgroundColor: Colors.blue.shade500,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  onPressed: () {
                    setState(() {
                      if (sendmsgC.text.isNotEmpty) {
                        sendMessage(sendmsgC.text, userid, widget.userid);
                        sendmsgC.clear();
                      }
                    });
                  },
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
