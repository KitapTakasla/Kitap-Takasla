

class ChatMenu {
  final DateTime time;
  final String text;
  final String name;
  final String imageUrl;
  final bool isOnline;
  final bool isRead;


  ChatMenu({
    required this.time,
    required this.text,
    required this.name,
    required this.imageUrl,
    required this.isOnline,
    required this.isRead,
  });

  Map<String, dynamic> getDataMap() {
    return {
      "time": time,
      "text": text,
      "name": name,
      "imageUrl": imageUrl,
      "isOnline": isOnline,
      "isRead": isRead,
    };
  }

  List<String> getKeys() { //TODO: check StreamBuilders with keys
    return ["time", "text", "name", "imageUrl", "isOnline", "isRead"];
  }
}