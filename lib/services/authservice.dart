import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screens/login.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  //Handles Auth
  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage(
              title: "Deprem Acil Yardım",
            );
          } else {
            return LoginPage();
          }
        });
  }

  //Sign out
  signOut() {
    FirebaseAuth.instance.signOut();
  }

  //SignIn
  signIn(AuthCredential authCreds) {
    FirebaseAuth.instance.signInWithCredential(authCreds);
  }

  signInWithOTP(smsCode, verId, context, name, surname, phoneNo) async {
    AuthCredential authCreds =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: smsCode);
    if (authCreds.token == null) {
      Fluttertoast.showToast(
          msg: "Kod doğrulanamadı.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 15.0);
    } else
      signIn(authCreds);
  }
}
