import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:takas_app/Utils/common.dart';
import 'package:takas_app/models/user.dart';
import 'package:takas_app/screens/chatScreens/chat.dart';
import '../../auth.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({Key? key}) : super(key: key);

  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  late var query;

  @override
  void initState() {
    super.initState();
    query = FirebaseFirestore.instance
        .collection('users')
        .where("id", isNotEqualTo: Auth().currentUserId())
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

                  UserData userData = UserData(
                      id: data["id"],
                      name: data["name"],
                      email: data["email"],
                      imageUrl: data["imageUrl"],
                      isOnline: data["isOnline"]);

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                            id: userData.id,
                            name: userData.name,
                            isOnline: userData.isOnline,
                            imageUrl: userData.imageUrl),
                      ),
                    ),
                    child:
                        userList(userData.imageUrl, userData.name, "Merhaba de"),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget userList(String url, String name, String message) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildProfileImage(url, 50),
        const SizedBox(
          width: 8.0,
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
                ],
              ),
              const SizedBox(
                height: 2.0,
              ),
              Row(
                children: [
                  Expanded(child: Text(message)),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
