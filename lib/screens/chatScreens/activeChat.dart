import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:takas_app/Utils/common.dart';
import 'package:takas_app/models/chatMenu.dart';
import 'package:takas_app/models/user.dart';
import 'package:takas_app/screens/chatScreens/chat.dart';
import '../../auth.dart';
import 'package:intl/intl.dart';

class ActiveChat extends StatefulWidget {
  const ActiveChat({Key? key}) : super(key: key);

  @override
  _ActiveChatState createState() => _ActiveChatState();
}

class _ActiveChatState extends State<ActiveChat> {
  late var query;

  @override
  void initState() {
    super.initState();
    query = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUserId())
        .collection("chatMenu")
        .orderBy("time", descending: true)
        .snapshots();
  }

  final _bookController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("yükleniyor");
        }



        return SingleChildScrollView(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              SizedBox(
                height: 50,
                width: 150,
                child: TextFormField(
                  controller: _bookController,
                  decoration: InputDecoration(
                    hintText: 'Kullanıcı ara',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      color: Colors.blue,
                      onPressed: () async {
                        setState(() {
                          query = FirebaseFirestore.instance
                              .collection('users')
                              .doc(Auth().currentUserId())
                              .collection("chatMenu")
                              .where("name",
                                  isGreaterThanOrEqualTo: _bookController.text)
                              .where("name",
                                  isLessThanOrEqualTo:
                                      "${_bookController.text}\uf7ff")
                              .snapshots();
                        });
                      },
                    ),
                  ),
                  onSaved: (String? value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                  },
                  validator: (String? value) {
                    return (value != null && value.contains('@'))
                        ? 'Do not use the @ char.'
                        : null;
                  },
                ),
              ),
              ListView(
                primary: false,
                shrinkWrap: true,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  ChatMenu chatMenu = ChatMenu(
                    name: data["name"],
                    text: data["text"],
                    time: (data['time'] as Timestamp).toDate(),
                    imageUrl: data["imageUrl"],
                    isOnline: data["isOnline"],
                    isRead: data["isRead"],
                  );

                  //var imagePath = data["imageUrl"];

                  //print("imagePath $imagePath");
                  //
                  DateTime dt = (data['time'] as Timestamp).toDate();
                  var d24 = DateFormat('dd/MM/yyyy, HH:mm').format(dt);

                  return GestureDetector(
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                id: document.id,
                                name: chatMenu.name,
                                isOnline: chatMenu.isOnline,
                                imageUrl: chatMenu.imageUrl,
                              ),
                            ),
                          ),
                      child: conversation(chatMenu.imageUrl, chatMenu.name,
                          chatMenu.text, d24, !chatMenu.isRead));
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget conversation(
    String url, String name, String message, String time, bool messageSeen) {
  return Padding(
    padding: const EdgeInsets.only(left: 8, top: 16, right: 8, bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildProfileImage(url, 50),
        const SizedBox(
          width: 5.0,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(time),
                ],
              ),
              const SizedBox(
                height: 3.0,
              ),
              Row(
                children: [
                  Expanded(child: Text(message)),
                  if (messageSeen)
                    const Icon(
                      Icons.check_circle,
                      size: 16.0,
                      color: Colors.green,
                    ),
                  if (!messageSeen)
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.grey,
                      size: 16.0,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
