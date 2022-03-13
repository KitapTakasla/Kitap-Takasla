import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:takas_app/Utils/cancelRequestDialog.dart';
import 'package:takas_app/models/item.dart';
import 'package:takas_app/screens/itemScreens/completeSwap.dart';

import '../../../auth.dart';
import '../../../Utils/common.dart';
import '../../../Utils/itemCard.dart';

myItems() {
  Widget _sizedContainer(Widget child) {
    return SizedBox(
      width: 100.0,
      child: Center(child: child),
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('items')
        .where("userId", isEqualTo: Auth().currentUserId())
        .snapshots(),
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

      return ListView(
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

          return Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                          child: _sizedContainer(CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            height: 160,
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ))),
                    ),
                    const SizedBox(width: 12,),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Item',
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Kitap Silme'),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              const ListTile(
                                                leading: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                title: Text("Kitabı gerçekten silmek istiyor musunuz?"),
                                              ),
                                              const SizedBox(width: 8),
                                              makeButton("Sil", () {
                                                Auth().deleteItem(document.id);
                                                Navigator.pop(context);
                                              }),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                            ),
                            title: Text(item.name, style: const TextStyle(fontSize: 25),),
                            subtitle: Text(
                              item.feature_1,
                              style:
                                  TextStyle(color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Yayın: " + item.feature_2,
                              style: TextStyle(color: Colors.black.withOpacity(0.6), fontStyle: FontStyle.italic),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              item.feature_3 + " Sayfa",
                              style: TextStyle(color: Colors.black.withOpacity(0.6), fontStyle: FontStyle.italic),
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: [
                              item.sendRequest.isNotEmpty
                                  ? TextButton(
                                      onPressed: () {
                                        Auth()
                                            .getRequestedItem(item.sendRequest)
                                            .then((value) {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title:
                                                      const Text('İsteği bırak'),
                                                  content: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          leading: const Icon(
                                                              Icons.album),
                                                          title: Text(value.name),
                                                          subtitle: Text(
                                                            value.sendRequest,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.6)),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        makeButton("Bırak", () {
                                                          Auth().cancelSwapRequest(
                                                              document.id,
                                                              item.sendRequest);
                                                          Navigator.pop(context);
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });

                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (_) => CancelRequestDialog(item: value, docId: document.id,),
                                          //   ),
                                          // );
                                        });
                                      },
                                      child: const Text('Yapılan isteği bırak'),
                                    )
                                  : Container(),
                              item.getRequest.isNotEmpty
                                  ? TextButton(
                                      onPressed: () {
                                        // Perform some action

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CompleteSwap(
                                                itemList: item.getRequest,
                                                desired: document.id),
                                          ),
                                        );
                                      },
                                      child: const Text('Takası Tamamla',
                                          style: TextStyle(
                                            color: Colors.green,
                                          )))
                                  : const Text("Gelen istek yok"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}
