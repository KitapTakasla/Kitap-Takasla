class Item {
  final String name;
  final String userId;
  final String userName;
  final DateTime time;
  final String imageUrl;
  final String feature_1;
  final String feature_2;
  final String feature_3;
  final List<dynamic> getRequest;
  final String sendRequest;

  Item({
    required this.name,
    required this.userId,
    required this.userName,
    required this.time,
    required this.imageUrl,
    required this.feature_1,
    required this.feature_2,
    required this.feature_3,
    required this.getRequest,
    required this.sendRequest,
  });

  Map<String, dynamic> getDataMap() {
    return {
      "name": name,
      "userId": userId,
      "userName": userName,
      "time": time,
      "imageUrl": imageUrl,
      "feature_1": feature_1,
      "feature_2": feature_2,
      "feature_3": feature_3,
      "getRequest": getRequest,
      "sendRequest": sendRequest,
    };
  }
}