import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:takas_app/auth.dart';
import 'package:takas_app/models/item.dart';

import '../../../Utils/itemCard.dart';

class AllItems extends StatefulWidget {
  const AllItems({Key? key}) : super(key: key);

  @override
  State<AllItems> createState() => _AllItemsState();
}

class _AllItemsState extends State<AllItems> {
  late var query;
  @override
  void initState() {
    super.initState();
    query = FirebaseFirestore.instance
        .collection('items')
        .where("userId", isNotEqualTo: Auth().currentUserId())
        .snapshots();
  }

  final _bookController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: query,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return SingleChildScrollView(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Container(
                height: 50,
                width: 150,
                child: TextFormField(
                  controller: _bookController,
                  decoration: InputDecoration(
                    hintText: 'Aramak istediğiniz kitap adını giriniz.',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      color: Colors.blue,
                      onPressed: () async {
                        setState(() {
                          query = FirebaseFirestore.instance
                              .collection('items')
                              .where("name", isGreaterThanOrEqualTo: _bookController.text)
                              .where("name", isLessThanOrEqualTo: "${_bookController.text}\uf7ff")
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
                    return (value != null && value.contains('@')) ? 'Do not use the @ char.' : null;
                  },
                ),
              ),
              ListView(
                primary: false,
                shrinkWrap: true,
                children: snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                  Item item = Item(
                      name: data["name"],
                      userId: data["userId"],
                      userName: data["userName"],
                      time: (data["time"] as Timestamp).toDate(),
                      imageUrl: data["imageUrl"],
                      feature_1: data["feature_1"],
                      feature_2: data["feature_2"],
                      feature_3: data["feature_3"],
                      getRequest: data["getRequest"],
                      sendRequest: data["sendRequest"]);

                  return ItemCard(data: item, docId: document.id);
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
