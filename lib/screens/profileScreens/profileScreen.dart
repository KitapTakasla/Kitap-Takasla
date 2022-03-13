import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:takas_app/Utils/common.dart';
import 'package:takas_app/auth.dart';
import 'package:takas_app/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
          elevation: 8,
          title: const Text(
            "Profilim",
            style: TextStyle(
              color: Colors.white,
            ),
          ),),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where("id", isEqualTo: Auth().currentUserId())
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
            padding: EdgeInsets.zero,
            children: snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              const double coverHeight = 400;
              const profileHeight = 144;
              double top = (coverHeight - profileHeight / 2);
              const bottom = profileHeight / 2;

              UserData userData = UserData(
                  id: data["id"],
                  name: data["name"],
                  email: data["email"],
                  imageUrl: data["imageUrl"],
                  isOnline: data["isOnline"]);

              return Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: bottom),
                          child: buildCoverImage(coverHeight)
                      ),
                      Positioned(
                          top: top,
                          child:
                          buildProfileImage(userData.imageUrl, profileHeight)),
                    ],
                  ),
                  buildContent(userData.name, userData.email)
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

Widget buildContent(name, title) => Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 18, height: 1.4),
        )
      ],
    );



Widget buildCoverImage(double coverHeight) => Container(
      color: Colors.grey,
      child: Image.asset("assets/images/library.jpg",
          width: double.infinity, height: coverHeight, fit: BoxFit.cover),
    );
