import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takas_app/models/item.dart';

import '../../auth.dart';

class CompleteSwap extends StatefulWidget {
  CompleteSwap({Key? key, this.itemList, this.desired}) : super(key: key);

  final itemList;
  final desired;

  @override
  _CompleteSwapState createState() => _CompleteSwapState();
}

class _CompleteSwapState extends State<CompleteSwap> {
  addFireBase() {}

  Widget _sizedContainer(Widget child) {
    return SizedBox(
      width: 100.0,
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitap değişimini yap"),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('items').where("userId", isNotEqualTo: Auth().currentUserId())
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return ListView(
              children:
              snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {
                Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

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

                if (!widget.itemList.contains(document.id)) {
                  return Container();
                }

                return GestureDetector(
                  onTap: () {

                    Auth().deleteAfterSwapComplete(widget.desired, document.id);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ClipRRect(
                            child: _sizedContainer(CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                            ))),
                        Expanded(
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(item.name),
                                  subtitle: Text(
                                    item.feature_1,
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    item.feature_2,
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.6)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
