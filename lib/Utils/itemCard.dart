import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:takas_app/models/item.dart';
import 'package:takas_app/screens/itemScreens/swapItemScreen.dart';

class ItemCard extends StatefulWidget {
  ItemCard({Key? key, required this.data, required this.docId}) : super(key: key);

  Item data;
  String docId;

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
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
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: 190,
                    imageUrl: widget.data.imageUrl,
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(width: 12,),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      trailing: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      title: Text(widget.data.name, style: const TextStyle(fontSize: 20)),
                      subtitle: Text(
                        widget.data.feature_1,
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Text(
                        "Yayın: " + widget.data.feature_2,
                        style: TextStyle(color: Colors.black.withOpacity(0.6), fontStyle: FontStyle.italic),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8),
                      child: Text(
                        widget.data.feature_3 + " Sayfa",
                        style: TextStyle(color: Colors.black.withOpacity(0.6), fontStyle: FontStyle.italic),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 12),
                      child: Text(
                        "Kitap sahibi: " + widget.data.userName,
                        style: TextStyle(color: Colors.black.withOpacity(0.6), fontStyle: FontStyle.italic),
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SwapItem(docId: widget.docId),
                              ),
                            );
                          },
                          child: const Text('Takas'),
                        ),
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
  }
}
