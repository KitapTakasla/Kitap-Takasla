import 'dart:async';
import 'dart:convert';
import 'dart:io' as i;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:takas_app/Utils/common.dart';
import 'package:takas_app/screens/homeScreens/DrawerScreen.dart';

import 'Sessions/authExceptionHandler.dart';
import 'main.dart';
import 'models/chatMenu.dart';
import 'models/item.dart';
import 'models/message.dart';
import 'models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;
  static final Auth _singleton = Auth._internal();

  factory Auth() {
    return _singleton;
  }

  Auth._internal();

  FirebaseFirestore db = FirebaseFirestore.instance;

  List<UserData> users = [];
  UserData me =
      UserData(id: "", name: "", email: "", imageUrl: "", isOnline: false);
  Map<String, dynamic> latestMessage = {};

  Future<String> downloadUrl(String name) async {
    FirebaseStorage storage =
        FirebaseStorage.instanceFor(bucket: 'gs://takas-e8b2b.appspot.com/');

    final ref = storage.refFromURL('gs://takas-e8b2b.appspot.com/' + name);

    try {
      // Get raw data.
      var url = await ref.getDownloadURL();
      // prints -> Hello World!
      print("downloaded data" + url);
      return url;
    } catch (e) {
      print("error while downloading  $e");
      return "";
    }
  }

  Future<String> uploadData(
      Uint8List data, String name, String? extension) async {
    FirebaseStorage storage =
        FirebaseStorage.instanceFor(bucket: 'gs://takas-e8b2b.appspot.com/');

    final ref = storage.refFromURL('gs://takas-e8b2b.appspot.com/' + name);

    try {
      if (extension != null) {
        await ref.putData(
            data, SettableMetadata(contentType: 'image/$extension'));
      } else {
        await ref.putData(data, SettableMetadata(contentType: 'image/png'));
      }
      return await ref.getDownloadURL();
    } catch (e) {
      // e.g, e.code == 'canceled'
      print("error while uploading data");
      return "";
    }
  }

  Future<void> uploadString() async {
    FirebaseStorage storage =
        FirebaseStorage.instanceFor(bucket: 'gs://takas-e8b2b.appspot.com/');

    final ref = storage.refFromURL('gs://takas-e8b2b.appspot.com/');

    final task = ref.child('web_3_text').putString("hello again!");

    try {
      // Storage tasks function as a Delegating Future so we can await them.
      TaskSnapshot snapshot = await task;
      print('Uploaded ${snapshot.bytesTransferred} bytes.');
    } catch (e) {
      // The final snapshot is also available on the task via `.snapshot`,
      // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
      print(task.snapshot);

      if (e == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
      // ...
    }
  }

  void addItem(Map<String, dynamic> itemDataMap) {
    // Call the user's CollectionReference to add a new user
    db
        .collection('items')
        .add(itemDataMap)
        .then((value) => print("Item Added"))
        .catchError((error) => print("Failed to add item: $error"));
  }

  void addUser(Map<String, dynamic> userDataMap) {
    // Call the user's CollectionReference to add a new user
    db
        .collection('users')
        .doc(currentUserId())
        .set(userDataMap)
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> updateUserChatMenuReadMessage(friendId) async {
    db
        .collection('users')
        .doc(currentUserId())
        .collection("chatMenu")
        .doc(friendId)
        .update({"isRead": true})
        .then((value) => print("Updated chatMenu"))
        .catchError((error) => print("Failed to updated chatMenu: $error"));
  }

  Future<void> updateUserMessageDate(
      friendId, text, name, imageUrl, isOnline) async {
    // Call the user's CollectionReference to add a new user

    final time = DateTime.now();

    ChatMenu chatMenuMe = ChatMenu(
      time: time,
      text: text,
      name: name,
      imageUrl: imageUrl,
      isOnline: isOnline,
      isRead: true,
    );

    ChatMenu chatMenuFriend = ChatMenu(
      time: time,
      text: text,
      name: me.name,
      imageUrl: me.imageUrl,
      isOnline: me.isOnline,
      isRead: false,
    );

    db
        .collection('users')
        .doc(friendId)
        .collection("chatMenu")
        .doc(currentUserId())
        .set(chatMenuFriend.getDataMap(), SetOptions(merge: true))
        .then((value) => print("Updated chatMenu"))
        .catchError((error) => print("Failed to updated chatMenu: $error"));

    db
        .collection('users')
        .doc(currentUserId())
        .collection("chatMenu")
        .doc(friendId)
        .set(chatMenuMe.getDataMap(), SetOptions(merge: true))
        .then((value) => print("Updated chatMenu"))
        .catchError((error) => print("Failed to updated chatMenu: $error"));
  }

  Future<void> updateUserStatus(bool isOnline) async {
    // Call the user's CollectionReference to add a new user

    print('User Status is $isOnline');

    return db
        .collection('users')
        .doc(currentUserId())
        .update({'isOnline': isOnline})
        .then((value) => print("Updated User Status"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<Item> getRequestedItem(desired) async {
    final document = await db.collection('items').doc(desired).get();

    Map<String, dynamic> data = document.data()!;

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

    return item;
  }

  Future<void> cancelSwapRequest(docId, desired) async {
    // removed desired from getRequest content
    db
        .collection('items')
        .doc(desired)
        .update({
          'getRequest': FieldValue.arrayRemove([docId])
        })
        .then((value) => print("Desired swap request"))
        .catchError((error) => print("Failed to desired swap request: $error"));

    // empty sendRequest in current item
    db
        .collection('items')
        .doc(docId)
        .update({'sendRequest': ""})
        .then((value) => print("Desired swap request"))
        .catchError((error) => print("Failed to sesired swap request: $error"));
  }

  Future<void> deleteItem(itemId) async {
    QuerySnapshot snap = await db.collection('items').get();

    snap.docs.forEach((document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

      // if income id's desired or own, make empty string all related items' send request.
      if (document.id == itemId) {
        for (String el in data["getRequest"]) {
          db
              .collection('items')
              .doc(el)
              .update({'sendRequest': ""})
              .then((value) => print("Desired own request"))
              .catchError(
                  (error) => print("Failed to Desired own request: $error"));
        }

        // also delete image from storage. desired and own
        FirebaseStorage storage = FirebaseStorage.instanceFor(
            bucket: 'gs://takas-e8b2b.appspot.com/');
        storage.refFromURL(data["imageUrl"]).delete();
      } else {
        List getR = data["getRequest"];

        // if income id's getRequest contains desired, delete.
        if (getR.contains(itemId)) {
          db
              .collection('items')
              .doc(document.id)
              .update({
                'getRequest': FieldValue.arrayRemove([itemId])
              })
              .then((value) => print("Desired swap request"))
              .catchError(
                  (error) => print("Failed to sesired swap request: $error"));
        }
      }
    });

    // delete item after swap
    db
        .collection('items')
        .doc(itemId)
        .delete()
        .then((value) => print("Deleted desired item"))
        .catchError((error) => print("Failed to deleted desired item: $error"));
  }

  Future<void> deleteAfterSwapComplete(desired, own) async {
    // Call the user's CollectionReference to add a new user

    QuerySnapshot snap = await db.collection('items').get();

    snap.docs.forEach((document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

      // if income id's desired or own, make empty string all related items' send request.
      if (document.id == desired || document.id == own) {
        for (String el in data["getRequest"]) {
          db
              .collection('items')
              .doc(el)
              .update({'sendRequest': ""})
              .then((value) => print("Desired own request"))
              .catchError(
                  (error) => print("Failed to Desired own request: $error"));
        }

        // also delete image from storage. desired and own
        FirebaseStorage storage = FirebaseStorage.instanceFor(
            bucket: 'gs://takas-e8b2b.appspot.com/');
        storage.refFromURL(data["imageUrl"]).delete();
      } else {
        List getR = data["getRequest"];

        // if income id's getRequest contains desired, delete.
        if (getR.contains(desired)) {
          db
              .collection('items')
              .doc(document.id)
              .update({
                'getRequest': FieldValue.arrayRemove([desired])
              })
              .then((value) => print("Desired swap request"))
              .catchError(
                  (error) => print("Failed to sesired swap request: $error"));
        }

        // if income id's getRequest contains own, delete.
        if (getR.contains(own)) {
          db
              .collection('items')
              .doc(document.id)
              .update({
                'getRequest': FieldValue.arrayRemove([own])
              })
              .then((value) => print("Desired swap request"))
              .catchError(
                  (error) => print("Failed to desired swap request: $error"));
        }
      }
    });

    // delete after swap
    db
        .collection('items')
        .doc(desired)
        .delete()
        .then((value) => print("Deleted desired item"))
        .catchError((error) => print("Failed to deleted desired item: $error"));

    db
        .collection('items')
        .doc(own)
        .delete()
        .then((value) => print("Deleted own item"))
        .catchError((error) => print("Failed to deleted own item: $error"));
  }

  Future<void> swapRequest(desired, own) async {
    // Call the user's CollectionReference to add a new user
    db
        .collection('items')
        .doc(desired)
        .update({
          'getRequest': FieldValue.arrayUnion([own])
        })
        .then((value) => print("Desired swap request"))
        .catchError((error) => print("Failed to sesired swap request: $error"));

    db
        .collection('items')
        .doc(own)
        .update({'sendRequest': desired})
        .then((value) => print("Desired own request"))
        .catchError((error) => print("Failed to Desired own request: $error"));
  }

  Future<void> sendMessage(Map<String, dynamic> messageDataMap) {
    // Call the user's CollectionReference to add a new user
    return db
        .collection('messages')
        .add(messageDataMap)
        .then((value) => print("Message added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> fetchMe() async {
    db.collection('users').doc(currentUserId()).get().then((data) {
      me = UserData(
          id: data["id"],
          name: data["name"],
          email: data["email"],
          imageUrl: data["imageUrl"],
          isOnline: data["isOnline"]);
    });
  }

  Future<void> fetchUser() async {
    print("enter fetch");

    // Call the user's CollectionReference to add a new user
    db
        .collection('users')
        .where("id", isNotEqualTo: Auth().currentUserId())
        .snapshots()
        .listen((event) {
      for (var docs in event.docChanges) {
        // Do something with change

        final doc = docs.doc;

        if (docs.type != DocumentChangeType.removed) {
          fetchLastMessage(doc);

          print(doc["name"]);
          users.add(UserData(
              id: doc["id"],
              name: doc["name"],
              email: doc["email"],
              imageUrl: doc["imageUrl"],
              isOnline: doc["isOnline"]));
        } else {
          print(doc["name"] + " is removed");
        }
      }
    });
  }

  Future<void> fetchLastMessage(docUser) async {
    db
        .collection('messages')
        .where("toFromUser",
            isEqualTo: {"to": Auth().currentUserId(), "from": docUser["id"]})
        .orderBy("time", descending: true)
        .limit(1)
        .snapshots()
        .listen((event) {
          print("Triggered message toFromUser");

          for (var docs in event.docChanges) {
            // Do something with change

            final doc = docs.doc;

            if (docs.type != DocumentChangeType.removed) {
              print(doc["text"]);

              //latestMessage[friendId] = doc["text"];

              //docUser["latestMessage"] = doc["text"];

              //phobiasStream.add(docUser);

              print(latestMessage.length);
            } else {
              print(doc["text"] + " is removed");
              //latestMessage.re
            }
          }
        });
  }

  // TODO: do email verification
  String currentUserEmail() {
    var user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      return user.email!;
    }
    return "";
    // here you write the codes to input the data into firestore
  }

  String currentUserId() {
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    }
    return "";
    // here you write the codes to input the data into firestore
  }

  Future<User?> signIn(String email, String password) async {
    UserCredential result;

    try {
      result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      print('sign in is successful');
      updateUserStatus(true);

      //uploadString();
      //print(downloadURL());

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw AuthExceptionHandler.handleException(e);
    }
  }

  Future<User?> signUp(name, email, password, url) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      addUser({
        "id": result.user?.uid,
        "name": name,
        "email": email,
        "imageUrl": url,
        "isOnline": true,
      });

      return result.user;
    } on FirebaseAuthException catch (e) {

      throw AuthExceptionHandler.handleException(e);
    }
  }

  clearAll() {
    users.clear();
  }

  Future<void> signOut() async {
    clearAll();

    try {
      updateUserStatus(false);
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      print(e.code + ' Could not signOut');
    }
  }
}
