import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickmsg/HomeScreens/Profile/seachuserprofile.dart';
import 'package:quickmsg/Ui/receivecard.dart';
import 'package:quickmsg/Ui/sendcard.dart';
import 'package:quickmsg/Ui/usertypemsg.dart';
import 'package:quickmsg/socketService/socketservice.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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
  late io.Socket socket;

  final userid = FirebaseAuth.instance.currentUser!.uid;
  List<UserTypeMsg> chats = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    socket = SocketService().socket!;
    socket.on(
      "message",
      (message) {
        if (message != null) {
          if (message["sender"] == widget.userid) {
            setState(() {
              chatSaveByUser(message["message"], "receiver");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              });
            });
          }
        }
      },
    );
  }

  void sendMessage(String message, sender, receiver) {
    if (sendmsgC.text.isNotEmpty) {
      SocketService().sendMessage(message, sender, receiver);
      setState(() {
        chatSaveByUser(message, "sender");
      });
    }
  }

  void chatSaveByUser(String message, String usertype) {
    final UserTypeMsg chatting = UserTypeMsg(message, usertype);
    if (mounted) {
      setState(() {
        chats.add(chatting);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        });
      });
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
            child: ListView.builder(
              controller: _scrollController,
              physics: ScrollPhysics(parent: PageScrollPhysics()),
              shrinkWrap: true,
              itemCount: chats.length + 1,
              itemBuilder: (context, index) {
                if (index == chats.length) {
                  return Container(
                    height: 20,
                  );
                }
                if (chats[index].usertype == "sender") {
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Sendcard(
                      message: chats[index].message,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Receivecard(
                      message: chats[index].message,
                    ),
                  );
                }
              },
            ),
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
