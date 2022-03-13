import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../auth.dart';
import 'common.dart';

class AddItemDialog extends StatefulWidget {
  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final itemName = TextEditingController();
  final itemFeature_1 = TextEditingController();
  final itemFeature_2 = TextEditingController();
  final itemFeature_3 = TextEditingController();

  var webImage;
  var imageName;
  var extension;

  bool itemNameValidate = false;
  bool itemFeatureValidate_1 = false;
  bool itemFeatureValidate_2 = false;
  bool itemFeatureValidate_3 = false;

  String itemNameMessage = "Lütfen Bu Alanı Boş Bırakmayın";
  String itemFeatureMessage_1 = "Lütfen Bu Alanı Boş Bırakmayın";
  String itemFeatureMessage_2 = "Lütfen Bu Alanı Boş Bırakmayın";
  String itemFeatureMessage_3 = "Lütfen Bu Alanı Boş Bırakmayın";

  bool validateTextField() {
    setState(() {
      itemNameValidate = itemName.text.isEmpty ? true : false;
      itemFeatureValidate_1 = itemFeature_1.text.isEmpty ? true : false;
      itemFeatureValidate_2 = itemFeature_2.text.isEmpty ? true : false;
      itemFeatureValidate_3 = itemFeature_3.text.isEmpty ? true : false;
    });

    // return if anyone is set as true
    for (var element in [
      itemNameValidate,
      itemFeatureValidate_1,
      itemFeatureValidate_2,
      itemFeatureValidate_3
    ]) {
      if (element) {
        return false;
      }
    }

    setState(() {
      itemNameValidate = false;
      itemFeatureValidate_1 = false;
      itemFeatureValidate_2 = false;
      itemFeatureValidate_3 = false;
    });
    return true;
  }

  _imgFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 950);

    var f = await image?.readAsBytes();

    setState(() {
      webImage = f;
      imageName = image?.name;
      extension = imageName.split('.').last;
    });
  }

  getAvatar() {
    return GestureDetector(
        onTap: () {
          _imgFromGallery();
        },
        child: CircleAvatar(
          radius: 55,
          backgroundColor: const Color(0xffFDCF09),
          child: (webImage != null)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.memory(
                    webImage!,
                    fit: BoxFit.fitHeight,
                  ))
              : Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(50)),
                  width: 100,
                  height: 100,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.grey[800],
                  ),
                ),
        ));
  }

  addFireBase() {
    if (validateTextField()) {
      if (webImage != null) {
        var imagePath = Auth().currentUserEmail() + "/items/" + imageName;

        Auth().uploadData(webImage!, imagePath, extension).then((url) {
          Auth().addItem({
            "name": itemName.text,
            "time": DateTime.now(),
            "userName": Auth().me.name,
            "userId": Auth().currentUserId(),
            "imageUrl": url,
            "feature_1": itemFeature_1.text,
            "feature_2": itemFeature_2.text,
            "feature_3": itemFeature_3.text,
            "getRequest": [],
            "sendRequest": ""
          });
        });
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text('Lütfen kitap resmi ekleyiniz'),
          action: SnackBarAction(
            label: 'Tamam',
            onPressed: () {
              //_imgFromGallery();
            },
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          getAvatar(),
          makeInput(label: "İsim", userController: itemName, validate: itemNameValidate, message: itemNameMessage),
          makeInput(label: "Yazar", userController: itemFeature_1, validate: itemFeatureValidate_1, message: itemFeatureMessage_1),
          makeInput(label: "Yayın", userController: itemFeature_2, validate: itemFeatureValidate_2, message: itemFeatureMessage_2),
          makeInput(label: "Sayfa Sayısı", userController: itemFeature_3, validate: itemFeatureValidate_3, message: itemFeatureMessage_3),
          makeButton("Kitap Ekle", addFireBase),
        ]),
      ),
    );
  }
}
