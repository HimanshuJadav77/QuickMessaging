// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;
// import '../Ui/usertypemsg.dart';
//
// class SocketService {
//   static final SocketService _singleton = SocketService._internal();
//
//   factory SocketService() {
//     return _singleton;
//   }
//
//   List<UserTypeMsg> chats = [];
//   final userid = FirebaseAuth.instance.currentUser!.uid;
//   // final ScrollController _scrollController = ScrollController();
//
//   void chatSaveByUser(String message, String usertype) {
//     final UserTypeMsg chatting = UserTypeMsg(message, usertype);
//
//     chats.add(chatting);
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//     //       duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
//     // });
//   }
//
//   void sendMessage(String message, sender, receiver) {
//     socket!.emit("message",
//         {"message": message, "sender": sender, "receiver": receiver});
//     chatSaveByUser(message, "sender");
//   }
//
//   io.Socket? _socket;
//
//   SocketService._internal();
//
// // Initialize socket connection
// //   void initSocket() {
// //     if (_socket == null) {
// //       _socket = io.io('http://your-socket-server-url', {
// //         'transports': ['websocket'],
// //         'autoConnect': true,
// //       });
// //
// //       _socket!.onConnect((_) {
// //         print("Connected to Socket.io server");
// //       });
// //
// //       _socket!.onDisconnect((_) {
// //         print("Disconnected from Socket.io server");
// //       });
// //     }
// //   }
//
//   void connect() {
//     _socket = io.io("http://192.168.43.51:5000", <String, dynamic>{
//       "transports": ["websocket"],
//       "autoConnect": false,
//     });
//     _socket!.connect();
//     _socket!.emit("usersid", userid);
//     _socket!.onConnect((data) {
//       // ignore: avoid_print
//       print("Connected");
//
//       // _socket!.on("message", (msg) {
//       //   chatSaveByUser(msg["message"], "receiver");
//       // });
//     }
//     );
//     _socket!.onDisconnect((_) {
//       // ignore: avoid_print
//       print("Disconnected from Socket.io server");
//     });
//   }
//
// // Get the socket instance
//   io.Socket? get socket => _socket;
//
// // Close the socket connection
//   void closeSocket() {
//     _socket?.disconnect();
//     _socket = null;
//   }
// }
