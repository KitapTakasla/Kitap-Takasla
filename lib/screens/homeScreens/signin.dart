import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:takas_app/auth.dart';
import '../../Utils/common.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final email = TextEditingController();
  final password = TextEditingController();

  bool emailValidate = false;
  bool passwordValidate = false;
  String emailMessage = "Lütfen Bu Alanı Boş Bırakmayın";
  String passwordMessage = "Lütfen Bu Alanı Boş Bırakmayın";

  bool validateTextField() {
    setState(() {
      emailValidate = email.text.isEmpty ? true : false;
      passwordValidate = password.text.isEmpty ? true : false;
    });

    // return if anyone is set as true
    for (var element in [emailValidate, passwordValidate]) {
      if (element) {
        return false;
      }
    }
    setState(() {
      emailValidate = false;
      passwordValidate = false;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black,),
        ), systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        const Text("Giriş Yap", style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                        ),),
                        const SizedBox(height: 20,),
                         Text("Hesabınıza Giriş Yapın", style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700]
                        ),),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: <Widget>[
                           makeInput(label: "Email", userController: email, validate: emailValidate, message: emailMessage),
                          makeInput(label: "Şifre", userController: password, obscureText: true, validate: passwordValidate, message: passwordMessage),
                        ],
                      ),
                    ),
                     Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        padding: const EdgeInsets.only(top: 3, left: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: const Border(
                            bottom: BorderSide(color: Colors.black),
                            top: BorderSide(color: Colors.black),
                            left: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                          )
                        ),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height: 60,
                          onPressed: () {
                            if (validateTextField()) {
                              Auth().signIn(email.text,  password.text).then((user) {
                                authSuccess(context);
                              }).catchError((onError) {
                                authFail(context, onError);
                              });
                            }
                          },
                          color: Colors.greenAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: const Text("Giriş Yap", style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18
                          ),),
                        ),
                      ),
                    ),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Text("Hesabınız Yok mu?"),
                        Text(" Üzülmeyin hemen Kaydolun", style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 18
                        ),),
                      ],
                    )
                  ],
                ),
              ),
               Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}