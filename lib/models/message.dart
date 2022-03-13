import 'package:takas_app/models/user.dart';

class Message {
  final DateTime time;
  final String text;
  final Map<String, dynamic> toFromUser;

  Message({
    required this.toFromUser,
    required this.time,
    required this.text,
  });

  Map<String, dynamic> getDataMap() {
    return {
      "toFromUser": toFromUser,
      "time": time,
      "text": text,
    };
  }
}