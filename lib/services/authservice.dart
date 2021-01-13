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
            while (Navigator.canPop(context)) Navigator.pop(context);

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
  signIn(AuthCredential authCreds, context) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(authCreds);
    } catch (e) {
      print("helo");
      print(e);
      Fluttertoast.showToast(
          msg: "Kod Doğrulanamadı.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          backgroundColor: Colors.black54,
          fontSize: 15.0);
    }
  }

  autosignIn(AuthCredential authCreds) async {
    await FirebaseAuth.instance.signInWithCredential(authCreds);
  }

  signInWithOTP(smsCode, verId, context, name, surname, phoneNo) async {
    AuthCredential authCreds =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: smsCode);

    signIn(authCreds, context);
  }
}
