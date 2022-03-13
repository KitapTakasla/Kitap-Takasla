import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takas_app/auth.dart';
import '../../Utils/common.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  var webImage;
  var imageName;
  var extension;

  _imgFromGallery() async {

    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxHeight: 950);
    var f = await image?.readAsBytes();

    setState(() {
     /* if (kIsWeb) {
        webImage = f;
      } else {
        _image = i.File((image?.path)!);
      }*/
      imageName = image?.name;
      extension = imageName.split('.').last;
      webImage = f;
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
        child:
            (webImage != null)
            ? ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child:
          Image.memory(
                webImage,
                fit: BoxFit.fitHeight,
              )
        )
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
      )
    );
  }

  bool nameValidate = false;
  bool emailValidate = false;
  bool passwordValidate = false;
  bool cPasswordValidate = false;

  String nameMessage = "Lütfen Bu Alanı Boş Bırakmayın";
  String emailMessage = "Lütfen Bu Alanı Boş Bırakmayın";
  String passwordMessage = "Lütfen Bu Alanı Boş Bırakmayın";
  String cPasswordMessage = "Lütfen Bu Alanı Boş Bırakmayın";
  String snackBarMessage = "";

  // bool nameCheck() {
  //   if (name.text.isEmpty) {
  //     setState(() {
  //
  //     });
  //     return true;
  //   }
  //   return false;
  // }

  bool validateTextField() {
    setState(() {
      nameValidate = name.text.isEmpty ? true : false;
      emailValidate = email.text.isEmpty ? true : false;
      passwordValidate = password.text.isEmpty ? true : false;
      cPasswordValidate = confirmPassword.text.isEmpty ? true : false;
    });

    // return if anyone is set as true
    for (var element in [nameValidate, emailValidate, passwordValidate, cPasswordValidate]) {
      if (element) {
        return false;
      }
    }

    setState(() {
      nameValidate = false;
      emailValidate = false;
      passwordValidate = false;
      cPasswordValidate = false;
    });
    return true;
  }

  bool comparePasswords() {
    if (password.text != confirmPassword.text) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios, size: 20, color: Colors.black,),
        ), systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery
              .of(context)
              .size
              .height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Text("Kaydolun ", style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),),
                  const SizedBox(height: 10,),
                  Text("Ücretsiz Hemen, Hesap Açın", style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700]
                  ),),
                ],
              ),
              Column(
                children: <Widget>[
                  getAvatar(),
                  makeInput(label: "İsim", userController: name, validate: nameValidate, message: nameMessage),
                  makeInput(label: "Email", userController: email, validate: emailValidate, message: emailMessage),
                  makeInput(label: "Şifre",
                      userController: password,
                      obscureText: true, validate: passwordValidate, message: passwordMessage),
                  makeInput(label: "Şifre Onayla",
                      userController: confirmPassword,
                      obscureText: true, validate: cPasswordValidate, message: cPasswordMessage),
                  const SizedBox(height: 50,),

                ],
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Kaydol'),
        icon: const Icon(Icons.thumb_up),
        backgroundColor: Colors.pink,
        onPressed: () {

          if (validateTextField()) {
            if (webImage != null) {
              if (comparePasswords()) {
                var imagePath = email.text + "/profile/" + imageName;
                Auth().uploadData(webImage, imagePath, extension).then((url) {
                  print("url: $url");
                  Auth().signUp(name.text, email.text, confirmPassword.text, url)
                      .then((user) {
                    authSuccess(context);
                  }).catchError((onError) {
                    authFail(context, onError);
                  });
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: const Text('Şifreniz aynı değil, kontrol ediniz.'),
                  action: SnackBarAction(
                    label: 'Tamam',
                    onPressed: () {
                      _imgFromGallery();
                    },
                  ),
                ));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: const Text('Lütfen profil resmi ekleyiniz'),
                action: SnackBarAction(
                  label: 'Tamam',
                  onPressed: () {
                    _imgFromGallery();
                  },
                ),
              ));
            }
          }
        },
      ),
    );
  }
}