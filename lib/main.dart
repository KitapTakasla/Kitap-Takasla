import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:takas_app/screens/homeScreens/firstScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'models/pushNotification.dart';

void registerNotification() async {

  late FirebaseMessaging messaging;
  messaging = FirebaseMessaging.instance;

  NotificationSettings setting = await messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  if (setting.authorizationStatus == AuthorizationStatus.authorized) {
    print("User granted the permission!");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      PushNotification? notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataTitle: message.data["title"],
          dataBody: message.data["body"],
      );

      showSimpleNotification(
        Text(notification.title!),
        subtitle: Text(notification.body!),
        background: Colors.cyan.shade700,
        duration: const Duration(seconds: 2),
      );


      // print("message recieved");
      // print(message.notification!.body);
    });

  } else {
    print("Permission declined");
  }

  messaging.getToken().then((value){
    print(value);
  });


  // background State
  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    print("${event.notification!.title} ${event.notification!.body} I am coming from background");
  });

  FirebaseMessaging.instance.getInitialMessage().then((event) {
    if (event != null) {
      print("${event.notification!.title} ${event.notification!.body} I am coming from terminated state");
    }
  });

  //messaging.subscribeToTopic("items");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(apiKey: "AIzaSyDrjI51sfTGbDT7mld9PR_Zbsu39jt7kxc",
            appId: "1:192869734379:web:296b926eb5b8eea9dbabae",
            messagingSenderId: "192869734379", projectId: "takas-e8b2b")
    );
  } else {
    await Firebase.initializeApp();
  }


  //registerNotification();


  runApp(
      OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const FirstScreen(),
          // When navigating to the "/" route, build the FirstScreen widget.
          // When navigating to the "/second" route, build the SecondScreen widget.
          // '/HomeScreen': (context) => const HomeScreen(),
          // '/MyItems': (context) => const MyItems(),
          // '/AllItems': (context) => const AllItems(),
        },
      ),
    )
  );
}