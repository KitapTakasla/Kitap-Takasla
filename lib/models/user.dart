import 'package:flutter/rendering.dart';

class UserData {
  String id;
  String name;
  String email;
  String imageUrl;
  bool isOnline;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.isOnline,
  });

  Map<String, dynamic> getDataMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "imageUrl": imageUrl,
      "isOnline": isOnline,
    };
  }
}