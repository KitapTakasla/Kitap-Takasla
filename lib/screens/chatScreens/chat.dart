import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:takas_app/Utils/chatBubble.dart';
import 'package:takas_app/Utils/sendMessage.dart';
import 'package:takas_app/models/message.dart';

import '../../auth.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key,
    required this.name,
    required this.id,
    required this.isOnline,
    required this.imageUrl}) : super(key: key);

  final String name;
  final String id;
  final bool isOnline;
  final String imageUrl;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  final ScrollController _sc = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth().updateUserChatMenuReadMessage(widget.id);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Auth().updateUserChatMenuReadMessage(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  )),
              const TextSpan(text: '\n'),
              widget.isOnline
                  ? const TextSpan(
                      text: "Online",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : const TextSpan(
                      text: 'Offline',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    )
            ],
          ),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            }),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where("toFromUser", whereIn: [ // index is used to use both where and orderBy.
                    {"to": widget.id, "from": Auth().currentUserId()},
                    {"to": Auth().currentUserId(), "from": widget.id}
                  ])
                  .orderBy('time')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {

                // to scroll down
                WidgetsBinding.instance?.addPostFrameCallback((_) => {_sc.jumpTo(_sc.position.maxScrollExtent)});

                if (snapshot.hasError) {
                  print(widget.id);
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }
                // TODO: move list to bottom when new message is sent
                return ListView(
                  controller: _sc,
                  padding: const EdgeInsets.all(20),
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;

                      Message message = Message(
                        toFromUser: data["toFromUser"],
                        time: (data['time'] as Timestamp).toDate(),
                        text: data["text"],
                      );

                      final bool isMe =
                          data["toFromUser"]["from"] == Auth().currentUserId();
                      return chatBubble(context, message, isMe);

                  }).toList(),
                );
              },
            ),
          ),
          sendMessageArea(context, widget.id, widget.name, widget.imageUrl, widget.isOnline),
        ],
      ),
    );
  }
}
