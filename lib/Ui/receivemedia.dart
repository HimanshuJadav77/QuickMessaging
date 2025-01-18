import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:quickmsg/Ui/snackbar.dart';

class Receivemedia extends StatefulWidget {
  const Receivemedia({
    super.key,
    this.time,
    this.iconData,
    this.filename,
    this.fileType,
    this.fileurl,
    this.senderId,
  });

  // ignore: prefer_typing_uninitialized_variables
  final senderId;

  // ignore: prefer_typing_uninitialized_variables
  final fileType;

  // ignore: prefer_typing_uninitialized_variables
  final filename;

  // ignore: prefer_typing_uninitialized_variables
  final time;

  // ignore: prefer_typing_uninitialized_variables
  final iconData;

  // ignore: prefer_typing_uninitialized_variables
  final fileurl;

  @override
  State<Receivemedia> createState() => _ReceivemediaState();
}

class _ReceivemediaState extends State<Receivemedia> {
  bool isDownloading = false;
  bool isDownloaded = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    checkFileExist();
  }

  deleteFromCloudStorage() async {
    String filename = widget.filename.toString().split(".").first;
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference file =
          storage.ref("UserSendDocs").child(widget.senderId).child(filename);
      await file.delete();
    } catch (e) {
      //
    }
  }

  download(savePath) {
    setState(() {
      isDownloading = true;
    });
    try {
      Dio dio = Dio();
      dio.download(
        widget.fileurl,
        savePath,
        onReceiveProgress: (received, total) async {
          final progress = (received / total) * 100;

          setState(() {
            _progress = progress;
          });

          if (progress == 100.0) {
            checkFileExist();
            deleteFromCloudStorage();
          }
        },
      );
    } catch (e) {
      showSnackBar(context, "$e");
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  checkFileExist() async {
    String filepath =
        '/storage/emulated/0/Download/Quickmsg/Files/${widget.filename}';
    bool exist = false;

    exist = await File(filepath).exists();

    return exist;
  }

  @override
  Widget build(BuildContext context) {
    final inkwell = GlobalKey();
    Directory filepath = Directory(
        '/storage/emulated/0/Download/Quickmsg/Files/${widget.filename}');
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 100,
          maxHeight: MediaQuery.of(context).size.width - 100,
        ),
        child: InkWell(
          key: inkwell,
          onTap: () {
            checkFileExist();
            if (isDownloaded && widget.fileType != "Unknown Type") {
              final renderbox =
                  inkwell.currentContext?.findRenderObject() as RenderBox;
              final position = renderbox.localToGlobal(Offset.zero);
              showMenu(
                color: Colors.white,
                elevation: 10,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                context: context,
                position: RelativeRect.fromLTRB(position.dx + 200,
                    position.dy + 30, position.dx + 400, position.dy + 100),
                items: [
                  PopupMenuItem<String>(
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        const Text('Open'),
                      ],
                    ),
                    onTap: () async {
                      Directory filepath = Directory(
                          '/storage/emulated/0/Download/Quickmsg/Files/${widget.filename}');
                      try {
                        if (widget.fileType == "Compressed File") {
                          showSnackBar(context,
                              "Go to Downloads In App folder for Compressed Files.");
                        }
                        await OpenFile.open(
                          filepath.path,
                        );
                      } catch (e) {
                        //
                      }
                    },
                  ),
                ],
              );
            }
          },
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black26),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            // color: Colors.blue.shade500,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(20)),
                    height: 70,
                    width: 230,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(
                          widget.iconData,
                          size: 30,
                          color: Colors.black,
                        ),
                        title: Text(
                          widget.filename,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 2,
                    right: 15,
                    child: Text(
                      widget.time,
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    )),
                _progress != 0.0 && _progress != 100.0
                    ? Positioned(
                        right: 25,
                        bottom: 25,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _progress / 100,
                            ),
                            Text("${_progress.toStringAsFixed(0)}%")
                          ],
                        ),
                      )
                    : Positioned(
                        top: 10,
                        right: 15,
                        child: FutureBuilder(
                            future: checkFileExist(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                isDownloaded = snapshot.data! as bool;
                                return IconButton.outlined(
                                    onPressed: () {
                                      if (!isDownloaded) {
                                        download(filepath.path);
                                      }
                                    },
                                    icon: Icon(isDownloaded
                                        ? Icons.download_done_outlined
                                        : Icons.download));
                              }
                              return Center();
                            })),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
